const googleMapsApiKey = (() => {
  const fromEnv = (process.env.VUE_APP_GOOGLE_API_KEY || "").trim();
  if (fromEnv) return fromEnv;

  if (typeof window !== "undefined") {
    return (window.VUE_APP_GOOGLE_API_KEY || "").trim();
  }

  return "";
})();

export function getGoogleMapsApiKey() {
  return googleMapsApiKey;
}
