import axios from "axios";

let baseURL = "https://egisapp.com.br/api/"; // Default base URL

if (window.location.href.includes("homol")) {
  baseURL = "https://homol.egisnet.com.br/api/";
}

export const httpEgisApp = axios.create({
    //baseURL: "https://egisapp.com.br/api/",
    baseURL: baseURL,
});
