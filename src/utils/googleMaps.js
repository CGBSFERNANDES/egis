const googleMapsApiKey = (process.env.VUE_APP_GOOGLE_API_KEY || "").trim();

export function getGoogleMapsApiKey() {
  return googleMapsApiKey;
}
