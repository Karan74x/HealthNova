const mongoose = require("mongoose");

// The six disease-risk categories in the project scope (documentation §1.2).
// Keys are what the apps send and what the prediction service understands;
// names are what is stored and shown.
const DISEASE_KEYS = {
  diabetes: "Diabetes",
  heart: "Heart Disease",
  liver: "Liver Disease",
  kidney: "Kidney Disease",
  stroke: "Stroke",
  hypertension: "Hypertension",
};
const DISEASES = Object.values(DISEASE_KEYS);

const predictionSchema = new mongoose.Schema(
  {
    //patient the prediction belongs to
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Patient is required"],
    },

    //selected disease-risk category
    disease: {
      type: String,
      enum: {
        values: DISEASES,
        message: "Disease must be one of: " + DISEASES.join(", "),
      },
      required: [true, "Disease is required"],
    },

    //health parameters submitted for the prediction
    inputs: {
      type: Object,
      required: [true, "Inputs are required"],
    },

    //outcome returned by the prediction service
    result: {
      type: String,
      required: [true, "Result is required"],
      trim: true,
    },

    //risk classification, where the service provides one
    riskLevel: {
      type: String,
      trim: true,
    },

    //confidence score, where the service provides one
    confidence: {
      type: Number,
      min: [0, "Confidence cannot be negative"],
      max: [100, "Confidence cannot exceed 100"],
    },
  },
  {
    // Automatically adds createdAt and updatedAt
    timestamps: true,
  },
);

predictionSchema.index({ patient: 1, createdAt: -1 });

const Prediction = mongoose.model("Prediction", predictionSchema);

module.exports = Prediction;
module.exports.DISEASES = DISEASES;
module.exports.DISEASE_KEYS = DISEASE_KEYS;
