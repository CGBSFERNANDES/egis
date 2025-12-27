import axios from "axios";

let baseURL = "https://egismob.com.br/api/"; // Default base URL

if (window.location.href.includes("homol")) {
  baseURL = "https://homol.egisnet.com.br/api/";
}

export const httpEgismob = axios.create({
    //baseURL: "https://egismob.com.br/api/",
    baseURL: baseURL,
});
