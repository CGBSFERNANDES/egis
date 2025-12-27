import axios from "axios";

let baseURL = "https://egisnet.com.br/api/"; // Default base URL

if (window.location.href.includes("homol")) {
  baseURL = "https://homol.egisapp.com.br/api/";
}


export const http = axios.create({
  //baseURL: 'https://www.gbs-egis.com.br:3000/api/'
  //baseURL: "https://34.203.196.98/api/",
  //baseURL: "https://egisnet.com.br/api/",
  baseURL: baseURL,
});
