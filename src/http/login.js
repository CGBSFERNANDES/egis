import Vue from 'vue'
import VueCryptojs from 'vue-cryptojs'


Vue.use(VueCryptojs)

var dados = ''
var senha = 'pedro'
senha = Vue.CryptoJS.AES.encrypt(senha, "00001001").toString()
alert(senha)
alert(senha)
alert(Vue.CryptoJS.AES.decrypt(senha, "00001001").toString(Vue.CryptoJS.enc.Utf8))

export default {
 tSenha: (senha) => {
   dados = Vue.CryptoJS.AES.encrypt(senha, "00001001").toString()
   alert(dados)
   return dados
 }
}
