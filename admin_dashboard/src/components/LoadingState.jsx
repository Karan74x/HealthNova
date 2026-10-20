export default function LoadingState({ message = "Loading" }) {
  return (
    <div className="state" role="status" aria-live="polite">
      <div className="spinner" />
      <p className="state-message">{message}</p>
    </div>
  );
}
