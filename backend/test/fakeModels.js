/*
 * A small in-memory stand-in for the Mongoose models.
 *
 * It exists so the routes, middleware and controllers can be exercised over
 * real HTTP without a MongoDB server. It implements only the query surface the
 * controllers actually use, and it is a test double - never loaded by the app.
 */
const { ObjectId } = require("bson");

const clone = (value) => (value === undefined ? value : JSON.parse(JSON.stringify(value)));

const idOf = (value) => (value && value._id ? String(value._id) : String(value));

function matches(doc, filter) {
  return Object.entries(filter).every(([key, condition]) => {
    if (key === "$or") {
      return condition.some((sub) => matches(doc, sub));
    }
    const actual = doc[key];
    if (condition instanceof RegExp) {
      return typeof actual === "string" && condition.test(actual);
    }
    if (condition && typeof condition === "object" && !Array.isArray(condition)) {
      if ("$in" in condition) {
        return condition.$in.map(String).includes(String(actual));
      }
      if ("$ne" in condition) {
        return String(actual) !== String(condition.$ne);
      }
      if ("$gte" in condition || "$lt" in condition) {
        const value = new Date(actual).getTime();
        if ("$gte" in condition && value < new Date(condition.$gte).getTime()) return false;
        if ("$lt" in condition && value >= new Date(condition.$lt).getTime()) return false;
        return true;
      }
    }
    if (actual instanceof Date || condition instanceof Date) {
      return new Date(actual).getTime() === new Date(condition).getTime();
    }
    return String(actual) === String(condition);
  });
}

/*
 * Mongoose query methods are chainable and only run when awaited, so the stub
 * returns a thenable that applies populate/select/sort on resolution.
 */
function project(doc, fields) {
  if (!doc || !fields) return doc;
  const keep = new Set(fields.split(/\s+/).filter(Boolean));
  keep.add("_id");
  const out = {};
  for (const key of Object.keys(doc)) {
    if (keep.has(key)) out[key] = doc[key];
  }
  return out;
}

class Query {
  constructor(run) {
    this.run = run;
    this.populates = [];
    this.projection = null;
  }
  populate(path, select) {
    this.populates.push(typeof path === "string" ? { path, select } : path);
    return this;
  }
  select(fields) {
    this.projection = fields;
    return this;
  }
  sort() {
    return this;
  }
  limit(count) {
    this.max = count;
    return this;
  }
  then(resolve, reject) {
    return Promise.resolve()
      .then(() => this.run(this.populates))
      .then((result) => (Array.isArray(result) && this.max ? result.slice(0, this.max) : result))
      .then((result) => {
        if (!this.projection) return result;
        return Array.isArray(result)
          ? result.map((doc) => project(doc, this.projection))
          : project(result, this.projection);
      })
      .then(resolve, reject);
  }
  catch(reject) {
    return this.then(undefined, reject);
  }
}

function createModel(name, registry) {
  const rows = [];

  const populate = (doc, paths) => {
    if (!doc) return doc;
    const out = clone(doc);
    for (const path of paths) {
      const field = path.path;
      const nested = path.populate;
      const refName = registry.refs[`${name}.${field}`];
      if (!refName || out[field] === undefined) continue;
      const target = registry.models[refName];
      const found = target.rows.find((row) => idOf(row) === idOf(out[field]));
      out[field] = found ? project(clone(found), path.select) : null;
      if (out[field] && nested) {
        const nestedRef = registry.refs[`${refName}.${nested.path}`];
        const nestedTarget = registry.models[nestedRef];
        if (nestedTarget) {
          const hit = nestedTarget.rows.find(
            (row) => idOf(row) === idOf(out[field][nested.path]),
          );
          out[field][nested.path] = hit ? project(clone(hit), nested.select) : null;
        }
      }
    }
    return out;
  };

  const model = {
    rows,
    find: (filter = {}) =>
      new Query((paths) => rows.filter((row) => matches(row, filter)).map((row) => populate(row, paths))),
    findOne: (filter = {}) =>
      new Query((paths) => {
        const hit = rows.find((row) => matches(row, filter));
        return hit ? populate(hit, paths) : null;
      }),
    findById: (id) =>
      new Query((paths) => {
        const hit = rows.find((row) => idOf(row) === String(id));
        return hit ? populate(hit, paths) : null;
      }),
    async create(doc) {
      const created = {
        _id: new ObjectId(),
        ...doc,
        createdAt: new Date(),
        updatedAt: new Date(),
        save: undefined,
      };
      delete created.save;
      rows.push(created);
      return {
        ...clone(created),
        _id: created._id,
        save: async () => {},
      };
    },
    async countDocuments(filter = {}) {
      return rows.filter((row) => matches(row, filter)).length;
    },
    async exists(filter = {}) {
      const hit = rows.find((row) => matches(row, filter));
      return hit ? { _id: hit._id } : null;
    },
    async distinct(field, filter = {}) {
      return [
        ...new Set(rows.filter((row) => matches(row, filter)).map((row) => String(row[field]))),
      ];
    },
    async updateOne(filter, update) {
      const hit = rows.find((row) => matches(row, filter));
      if (hit) Object.assign(hit, update.$set || {});
      return { modifiedCount: hit ? 1 : 0 };
    },
    findByIdAndUpdate(id, update) {
      return new Query((paths) => {
        const hit = rows.find((row) => idOf(row) === String(id));
        if (!hit) return null;
        Object.assign(hit, update.$set || {});
        for (const key of Object.keys(update.$unset || {})) delete hit[key];
        hit.updatedAt = new Date();
        return populate(hit, paths);
      });
    },
    findOneAndUpdate(filter, update, options = {}) {
      return new Query((paths) => {
        const hit = rows.find((row) => matches(row, filter));
        if (!hit) return null;
        Object.assign(hit, update.$set || {});
        hit.updatedAt = new Date();
        return options.new === false ? populate(hit, paths) : populate(hit, paths);
      });
    },
    async findByIdAndDelete(id) {
      const index = rows.findIndex((row) => idOf(row) === String(id));
      if (index === -1) return null;
      return rows.splice(index, 1)[0];
    },
    async deleteMany(filter = {}) {
      const keep = rows.filter((row) => !matches(row, filter));
      const removed = rows.length - keep.length;
      rows.length = 0;
      rows.push(...keep);
      return { deletedCount: removed };
    },
  };

  // findById(...).save() is used by the status endpoints
  const originalFindById = model.findById;
  model.findById = (id) => {
    const query = originalFindById(id);
    const then = query.then.bind(query);
    query.then = (resolve, reject) =>
      then((doc) => {
        if (!doc) return resolve ? resolve(doc) : doc;
        const live = rows.find((row) => idOf(row) === String(id));
        const wrapped = {
          ...doc,
          _id: live._id,
          set status(value) {
            live.status = value;
          },
          get status() {
            return live.status;
          },
          save: async () => {},
        };
        return resolve ? resolve(wrapped) : wrapped;
      }, reject);
    return query;
  };

  return model;
}

function buildRegistry() {
  const registry = {
    models: {},
    refs: {
      "Doctor.user": "User",
      "Appointment.patient": "User",
      "Appointment.doctor": "Doctor",
      "Prediction.patient": "User",
    },
  };
  for (const name of ["User", "Doctor", "Appointment", "Prediction"]) {
    registry.models[name] = createModel(name, registry);
  }
  return registry;
}

module.exports = { buildRegistry, ObjectId };
