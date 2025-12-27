import axios from "axios";

export const http = axios.create({
  //baseURL: 'https://www.gbs-egis.com.br:3000/api/'
  baseURL: "https://www.receitaws.com.br/v1/cnpj/"
});

