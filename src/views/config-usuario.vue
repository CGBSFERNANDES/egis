<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="text-h6 text-bold margin1">
      Configuração do Usuário
    </div>
    <div class="row justify-center">
      <q-expansion-item
        class="overflow-hidden metade-tela margin1 "
        style="border-radius: 20px; height:auto; "
        icon="password"
        label="Senha"
        default-opened
        header-class="bg-orange-9 text-white items-center"
        expand-icon-class="text-white"
      >
        <q-card style=" min-height:300px">
          <q-card-section>
            <div class="row text-bold text-subtitle2 text-center margin1">
              Nova Senha
            </div>
            <q-input
              v-model="pass1"
              class="row margin1"
              label="Nova Senha"
              hint="Máximo de 10 caracteres"
              maxlength="10"
              :type="isPwd1 ? 'password' : 'text'"
            >
              <template v-slot:prepend>
                <q-icon name="lock" />
              </template>
              <template v-slot:append>
                <q-btn
                  round
                  flat
                  color="black"
                  @click="isPwd1 = !isPwd1"
                  :icon="isPwd1 ? 'visibility_off' : 'visibility'"
                />
              </template>
            </q-input>
            <br />
            <q-input
              v-model="pass2"
              class="row margin1"
              label="Confirmação"
              hint="Máximo de 10 caracteres"
              maxlength="10"
              :type="isPwd2 ? 'password' : 'text'"
            >
              <template v-slot:prepend>
                <q-icon name="lock" />
              </template>
              <template v-slot:append>
                <q-btn
                  round
                  flat
                  color="black"
                  @click="isPwd2 = !isPwd2"
                  :icon="isPwd2 ? 'visibility_off' : 'visibility'"
                />
              </template>
            </q-input>
            <br />
            <div class="row justify-end margin1">
              <q-btn
                color="positive"
                icon="check"
                rounded
                label="Confirmar"
                flat
                @click="confirmaSenha()"
              />
            </div>
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-expansion-item
        class=" overflow-hidden metade-tela margin1 "
        style="border-radius: 20px"
        icon="photo_camera"
        label="Imagem de Perfil"
        default-opened
        header-class="bg-orange-9 text-white items-center"
        expand-icon-class="text-white"
      >
        <q-card style=" min-height:300px">
          <q-card-section v-if="carregando">
            <q-circular-progress
              indeterminate
              size="50px"
              color="primary"
              class="q-ma-md"
            />
            <div>
              {{ msg_save }}
            </div>
          </q-card-section>

          <q-card-section v-else>
            <div class="row text-bold text-subtitle2 text-center margin1 ">
              Imagem de Perfil
            </div>
            <div>
              <q-file
                outlined
                v-model="img"
                accept=".jpg"
                max-file-size="200000"
                hint="Apenas jpg, tamanho máximo permitido 200Kb"
              >
                <template v-slot:prepend>
                  <q-icon name="attach_file" />
                </template>
              </q-file>
            </div>

            <div class="row margin1">
              <q-space />

              <q-btn
                style="float:right"
                color="positive"
                label="Confirmar"
                class="margin1"
                flat
                rounded
                icon="check"
                @click="onGravarImagem()"
              />

              <q-btn
                style="float:right"
                color="negative"
                label="Cancelar"
                class="margin1"
                flat
                rounded
                icon="close"
                @click="onCancelar()"
              />
            </div>
          </q-card-section>
        </q-card>
      </q-expansion-item>
    </div>

    <div class="row justify-center">
      <q-expansion-item
        class=" overflow-hidden metade-tela margin1 sem-padding 2"
        style="border-radius: 20px"
        icon="mark_email_read"
        label="E-mail"
        default-opened
        header-class="bg-orange-9 text-white items-center"
        expand-icon-class="text-white"
      >
        <q-card style=" min-height:300px" class="sem-padding">
          <q-card-section>
            <q-input
              v-model="email"
              class="row margin1"
              label="E-mail"
              @blur="ConfereGmail()"
              type="email"
            >
              <template v-slot:prepend>
                <q-icon name="contact_mail" />
              </template>
            </q-input>
            <q-input
              v-model="passEmail"
              class="row margin1"
              label="Senha do E-mail"
              type="password"
            >
              <template v-slot:prepend>
                <q-icon name="vpn_key" />
              </template>
            </q-input>

            <q-input
              v-model="servidor"
              class="row margin1"
              label="Servidor (SMTP)"
              type="text"
            >
              <template v-slot:prepend>
                <q-icon name="http" />
              </template>
            </q-input>
            <q-input
              v-model="door"
              class="row margin1"
              label="Porta"
              type="number"
            >
              <template v-slot:prepend>
                <q-icon name="door_front" />
              </template>
            </q-input>

            <div class="row justify-end">
              <div class="col">
                <q-btn
                  color="positive"
                  icon="check"
                  label="Confirmar"
                  flat
                  rounded
                  @click="SalvaEmail()"
                  style="float: right"
                  class="margin1"
                />
              </div>
            </div>
          </q-card-section>
        </q-card>
      </q-expansion-item>

      <q-expansion-item
        class=" overflow-hidden metade-tela margin1 sem-padding "
        style="border-radius: 20px"
        icon="contact_mail"
        label="Contato"
        default-opened
        header-class="bg-orange-9 text-white items-center"
        expand-icon-class="text-white"
      >
        <q-card style=" min-height:350px" class="sem-padding">
          <q-card-section>
            <q-input
              v-model="WhatsApp"
              class="row margin1"
              mask="(##) #####-####"
              label="WhatsApp Pessoal"
              type="text"
            >
              <template v-slot:prepend>
                <q-icon name="contact_phone" />
              </template>
            </q-input>

            <q-input
              v-show="cd_vendedor > 0"
              v-model="WhatsAppVendedor"
              class="row margin1"
              mask="(##) #####-####"
              label="WhatsApp Comercial"
              type="text"
            >
              <template v-slot:prepend>
                <q-icon name="sell" />
              </template>
            </q-input>
            <div class="row justify-end">
              <div class="col">
                <q-btn
                  color="positive"
                  icon="check"
                  label="Confirmar"
                  flat
                  rounded
                  @click="SalvaContato()"
                  style="float: right"
                  class="margin1"
                />
              </div>
            </div>
          </q-card-section>
        </q-card>
      </q-expansion-item>
    </div>
    <q-dialog v-model="gmail">
      <q-card style="width: 700px; max-width: 80vw;">
        <q-card-section>
          <div class="text-h6">Gmail idêntificado!</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          Para que sua conta utilize envios usando um dominio Gmail é necessário
          que a senha de e-mail seja gerada para aplicativos.
          <br />
          <q-separator class="margin1" />

          <p>
            Acesse
            <a href="https://myaccount.google.com/security" target="_blank"
              >https://myaccount.google.com/security</a
            >
          </p>
          <q-img
            src="https://s3.amazonaws.com/movidesk-files/E37AADB70B8D6CBEABC74C72ED702A7E"
          >
            <div class="absolute-bottom text-subtitle1 text-center">
              Conclua a Verificação de duas etapas
            </div>
          </q-img>
          <p>
            <q-img
              src="https://s3.amazonaws.com/movidesk-files/C8D624945E5F68F3F40D0E46322F7559"
            >
              <div class="absolute-bottom text-subtitle1 text-center">
                Por último, solicite a senha de aplicativo na aba "Senhas de
                app"
              </div>
            </q-img>
          </p>
        </q-card-section>

        <q-card-actions align="right" class="bg-white text-primary">
          <q-btn
            flat
            label="OK"
            rounded
            @click="this.gmail = false"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";
import funcao from "../http/funcoes-padroes";
import axios from "axios";

export default {
  components: {},
  data() {
    return {
      pass1: "",
      isPwd1: true,
      cd_empresa: localStorage.cd_empresa,
      expandedPassword: false,
      expandedImage: false,
      msg_save: "Aguarde...",
      pass2: "",
      isPwd2: true,
      cd_usuario: localStorage.cd_usuario,
      carregando: false,
      door: "",
      servidor: "",
      isDropZoneActive: false,
      WhatsApp: "",
      imageSource: "",
      textVisible: true,
      progressVisible: false,
      progressValue: 0,
      img: [],
      expanded: false,
      passEmail: "",
      allowedFileExtensions: [".jpg", ".jpeg", ".png"],
      email: "",
      ds_imagem: "",
      api: "759/1159",
      gmail: false,
      WhatsAppVendedor: "",
      cd_vendedor: 0,
    };
  },
  async created() {
    this.cd_vendedor = await funcao.buscaVendedor(this.cd_usuario);
    this.cd_vendedor = this.cd_vendedor.cd_vendedor;
    this.cd_usuario = localStorage.cd_usuario;
    await this.ConsultaEmail();
    await this.ConsultaContato();
  },
  methods: {
    async ConsultaContato() {
      let c = {
        cd_parametro: 4,
        cd_usuario: this.cd_usuario,
      };
      let send = await Incluir.incluirRegistro(this.api, c);
      if (send[0].Cod == 0) {
        return;
      }
      this.WhatsApp = send[0].cd_celular_usuario;
      this.WhatsAppVendedor = send[0].cd_celular_vendedor;
    },
    async SalvaContato() {
      //if (this.WhatsApp.length < 15 || this.WhatsAppVendedor.length < 15) {
      //  notify("Digite corretamente os números!");
      //  return;
      //}
      let s = {
        cd_parametro: 3,
        cd_celular_usuario: this.WhatsApp,
        cd_celular_vendedor: this.WhatsAppVendedor,
        cd_usuario: this.cd_usuario,
        cd_empresa: this.cd_empresa,
      };
      let send = await Incluir.incluirRegistro(this.api, s);
      notify(send[0].Msg);
    },
    async ConfereGmail() {
      let conferencia = this.email;
      this.gmail = false;

      if (conferencia.indexOf("@") == -1 || conferencia.indexOf(".") == -1) {
        notify("Digite o E-mail corretamente!");
        return;
      }
      conferencia = conferencia.slice(
        conferencia.indexOf("@") + 1,
        conferencia.indexOf(".")
      );
      if (conferencia.toUpperCase() == "GMAIL") {
        this.gmail = true;
      }
    },
    async ConsultaEmail() {
      let c = {
        cd_parametro: 2,
        cd_usuario: this.cd_usuario,
        cd_empresa: this.cd_empresa,
      };

      let send = await Incluir.incluirRegistro(this.api, c);

      if (send[0].Cod == 0) return;
      this.door = send[0].qt_porta_envio;
      this.email = send[0].nm_email_usuario;
      this.servidor = send[0].nm_servidor_email;
    },
    async SalvaEmail() {
      if (this.email.length <= 5) {
        notify("Digite o e-mail corretamente!");
        return;
      }
      if (!!this.passEmail.length == false) {
        notify("Digite a senha do email corretamente!");
        return;
      }
      if (this.servidor.length <= 5) {
        notify("Digite o servidor SMTP corretamente!");
        return;
      }
      if (!!this.door == false) {
        notify("Digite a porta corretamente!");
        return;
      }

      let json_update_email = {
        cd_parametro: 1,
        nm_usuario_email: this.email,
        cd_senha_email_usuario: this.passEmail,
        nm_servidor_email: this.servidor,
        qt_porta_envio: this.door,
        cd_usuario: this.cd_usuario,
        cd_empresa: this.cd_empresa,
      };
      let send = await Incluir.incluirRegistro(this.api, json_update_email);
      notify(send[0].Msg);
    },
    async confirmaSenha() {
      if (this.pass1 !== this.pass2) {
        notify("Senhas não conferem!");
        return;
      } else if (this.pass1.length > 10) {
        notify("Senha muito grande!");
        return;
      }
      let api = "560/779";
      let json_update_password = {
        cd_parametro: 5,
        cd_usu: this.cd_usuario,
        cd_senha_repnet_usuario: this.pass1,
      };
      let atualizado = await Incluir.incluirRegistro(api, json_update_password);
      notify(atualizado[0].Msg);
    },
    onDropZoneEnter(e) {
      if (e.dropZoneElement.id == "dropzone-external") {
        this.isDropZoneActive = true;
      }
    },
    onDropZoneLeave(e) {
      if (e.dropZoneElement.id == "dropzone-external") {
        this.isDropZoneActive = false;
      }
    },
    onUploaded(e) {
      const file = e.file;
      const fileReader = new FileReader();
      fileReader.onload = () => {
        this.isDropZoneActive = false;
        this.imageSource = fileReader.result;
      };
      fileReader.readAsDataURL(file);
      this.textVisible = false;
      this.progressVisible = false;
      this.progressValue = 0;
    },
    onProgress(e) {
      this.progressValue = (e.bytesLoaded / e.bytesTotal) * 100;
    },
    onUploadStarted() {
      this.imageSource = "";
      this.progressVisible = true;
    },
    onCancelar() {
      this.imageSource = "";
      this.$router.push({ name: "home" });
    },
    async onGravarImagem() {
      this.carregando = true;
      this.msg_save = "Salvando imagem...";
      /////////////////////////////////////////////////
      const form = new FormData(); //identico ao <form> usado no HTML porém criado com JS
      form.append("nm_empresa", "Perfil");
      form.append("nm_usuario_imagem", localStorage.cd_usuario);
      form.append("file", this.img);
      const options = {
        method: "POST",
        url: "https://egis-store.com.br/api/upload-server",
        headers: {
          "Content-Type": "multipart/form-data", // Define o tipo de conteúdo como multipart/form-data
        },
        data: form, // Define o corpo da requisição como o objeto FormData
      };
      axios(options)
        .then(async (response) => {
          ////Caminho padrao no servidor
          notify("Documento inserido com sucesso");
        })
        .catch((error) => {
          console.error("Erro:", error);
          notify("Não foi possível salvar o documento");
        });
      /////////////////////////////////////////////////
      //Insere/Atualiza tabela de usuario_imagem com o caminho da imagem
      let json_update_img_perfil = {
        cd_menu: 1,
        cd_parametro: 1,
        cd_usuario: localStorage.cd_usuario,
        nm_caminho_imagem: `https://egis-store.com.br/img/perfil/${this.img.name}`,
      };
      let response_img_perfil = await Incluir.incluirRegistro(
        "897/1377",
        json_update_img_perfil
      ); // pr_modulo_processo_egismob_post -> pr_egismob_usuario
      this.$store._mutations.SET_Usuario.nm_caminho_imagem = `https://egis-store.com.br/img/perfil/${this.img.name}`;
      notify(response_img_perfil[0].Msg);
      /////////////////////////////////////////////////
      this.msg_save = "Salvando na Base de Dados...";
      this.carregando = false;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 1vh 1vw;
  padding: 0;
}
.inline {
  display: inline-flex;
}
.metade-tela {
  width: 45vw;
}
.sem-padding {
  padding: none;
}
@media (max-width: 900px) {
  .metade-tela {
    width: 95%;
  }
}
</style>
