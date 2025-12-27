<template>
  <div class="tela">
    <img class="imagem" src="https://www.egisnet.com.br/img/logo_gbstec_sistema.jpg" alt="Logotipo GBS">
    <div class="q-pa-md stepper-container">
     <q-stepper 
       class= "stepper-container"
       v-model="step"
       ref="stepper"
       color="primary"
       animated
     >
       <q-step
         :name="1"
         title="Formulario para cadastro"
         caption="Preencha seus dados para iniciar"
         icon="settings"
         :done="step > 1"
       >
         <div class="input_step1">
          <div class="input-checkbox-wrapper" >
             <div class=checkboxform>
             <q-input 
               class="formulario"
               outlined 
               type="text"
               lazy-rules
               v-model="nome"  
               label="Nome Completo" 
              :rules=" [val => val.length > 0 || 'Digite o seu nome' ]"  
             />
             
             <q-checkbox v-model="checkboxNome" @input="nomeRespon" label="O contato será feito com essa pessoa?"/>
             </div>
             <q-input 
               class="formulario"
               outlined 
               type="text"
               lazy-rules
               v-model="negocio" 
               label="Qual o nome do seu negócio" 
               :rules=" [val => val && val.length > 0 || 'Digite o nome completo da sua empresa' ]"
             />
             <q-input
               class="formulario" 
               outlined
               type="text"
               lazy-rules
               v-model="cargo"  
               label= "Cargo" 
              :rules=" [val => val.length > 0 || 'Digite o seu Cargo de Trabalho' ]"  
             />
            <div class="checkboxform">
             <q-input 
              class="formulario"
              outlined
              type="text" 
              v-model="numeroCelular" 
              mask="(##) #####-####"
              label="Celular"
              lazy-rules
              :rules="[val => val.toString().length === 15 || 'Seu número está incorreto']" 
              
            />
              <q-checkbox v-model="checkboxNumbero" @input="numCelular" label="Este Numero serve para contato ?" 

              />
            </div>
            
             <q-input 
               class="formulario"
               outlined
               v-model="email" 
               label="E-mail" 
               lazy-rules
               type="email"
               :rules="[val => val && val.length > 0 || 'O e-mail é obrigatório', val => /.+@.+\..+/.test(val) || 'E-mail inválido']"
               />
             
           </div>
         </div>
       </q-step>
 
       <q-step 
         :name="2"
         title="Sobre o seu negócio"
         caption="Começando a conhecer melhor o seu negócio"
         icon="business_chip"
         :done="step > 2"
       >
       <div class="negocio">
      <q-btn
        icon="hail"
        icon-right
        size="lg"
        :color="mudaCorBotao('Trabalho Sozinho')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Trabalho Sozinho"
        @click="tipoNegocio('Trabalho Sozinho')"
      >
        <q-tooltip>
          Não Tenho Funcionarios
        </q-tooltip>
      </q-btn>

      <q-btn
        icon="group"
        icon-right
        size="lg"
        :color="mudaCorBotao('Microempresa')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Microempresa"
        @click="tipoNegocio('Microempresa')"
      >
        <q-tooltip>
          Até 9 Funcionarios
        </q-tooltip>
      </q-btn>

      <q-btn
        icon="groups"
        icon-right
        size="lg"
        :color="mudaCorBotao('Pequena Empresa')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Pequena Empresa"
        @click="tipoNegocio('Pequena Empresa')"
      >
        <q-tooltip>
          Entre 10 e 49 Funcionarios
        </q-tooltip>
      </q-btn>

      <q-btn
        icon="cottage"
        icon-right
        size="lg"
        :color="mudaCorBotao('Média Empresa')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Média Empresa"
        @click="tipoNegocio('Média Empresa')"
      >
        <q-tooltip>
          Entre 50 e 99 Funcionarios
        </q-tooltip>
      </q-btn>

      <q-btn
        icon="apartment"
        icon-right
        size="lg"
        :color="mudaCorBotao('Grande Empresa')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Grande Empresa"
        @click="tipoNegocio('Grande Empresa')"
      >
        <q-tooltip>
          Mais de 100 Funcionarios
        </q-tooltip>
      </q-btn>

      <q-btn
        icon="cases"
        icon-right
        size="lg"
        :color="mudaCorBotao('Redes e Franquias')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Redes e Franquias"
        @click="tipoNegocio('Redes e Franquias')"
      >
        <q-tooltip>
          Sou uma rede de Franquias
        </q-tooltip>
      </q-btn>
  </div>

  <div class="q-pa-md" id="indicacao">
    <q-btn-dropdown color="deep-orange-5" padding="10px" label="Como nos Conheceu">
      <q-list class="lista">
        <q-item clickable v-close-popup @click="onItemClick('Instagram')">
          <q-item-section>
            <q-item-label>Instagram</q-item-label>
          </q-item-section>
        </q-item>

        <q-item clickable v-close-popup @click="onItemClick('Feiras')">
          <q-item-section>
            <q-item-label>Feiras</q-item-label>
          </q-item-section>
        </q-item>

        <q-item clickable v-close-popup @click="onItemClick('Indicação')">
          <q-item-section>
            <q-item-label>Indicação</q-item-label>
          </q-item-section>
        </q-item>

        <q-item clickable v-close-popup @click="onItemClick('Vendedor')">
          <q-item-section>
            <q-item-label>Vendedor</q-item-label>
          </q-item-section>
        </q-item>

        <q-item clickable v-close-popup @click="onItemClick('Pesquisa Google')">
          <q-item-section>
            <q-item-label>Pesquisa Google</q-item-label>
          </q-item-section>
        </q-item>

        <q-item clickable v-close-popup @click="onItemClick('Outros')">
          <q-item-section>
            <q-item-label>Outros</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-btn-dropdown>

    <div class="inputbotoes">
      <q-input
        outlined
        type="text"
        v-if="mostraInputUser"
        v-model="textoIndicacao"
        label="Digite o usuario ou se foi por anuncios"
        :rules=" [val => val.length > 0 || 'Esse campo não pode ficar em branco' ]"
      />
      
      <q-input
        outlined
        type="text"
        v-if="mostraInputGeral"
        v-model="textoIndicacao"
        label="Conte como foi ?"
        :rules=" [val => val.length > 0 || 'Esse campo não pode ficar em branco' ]"
      />
      
      <q-input
        outlined
        type="text"
        v-if="mostraInputIndica"
        v-model="textoIndicacao"
        label="Conte com quem nos conheceu ?"
        :rules=" [val => val.length > 0 || 'Esse campo não pode ficar em branco' ]"
      />
    </div>
  </div>
</q-step>
       <q-step
         :name="3"
         title="Serviços Necessarios"
         caption="Quais serviços sua empresa está buscando"
         icon="manage_accounts"
         :done="step > 3"
       >
       <div class="servicos">       
      <q-btn  
       icon="payments"
       icon-right
       size="lg"
       :color="mudaCorBotao('Financeiro')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Financeiro"
       @click="tipoServico('Financeiro')"
     />
     <q-btn
       icon="shopping_cart"
       icon-right
       size="lg"
       :color= "mudaCorBotao('Compras')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Compras"
       @click="tipoServico('Compras')"
     />
     <q-btn
       icon="inventory"
       icon-right
       size="lg"
       :color= "mudaCorBotao('Controle de Estoque')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Controle de Estoque"
       @click="tipoServico('Controle de Estoque')"
     />
     <q-btn
       icon="point_of_sale"
       icon-right
       size="lg"
       :color = "mudaCorBotao('Contabilidade')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Contabilidade"
       @click="tipoServico('Contabilidade')"
     />
     <q-btn
       icon="flight_takeoff"
       icon-right
       size="lg"
       :color = "mudaCorBotao('Importação e Exportação')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Importação e Exportação"
       @click="tipoServico('Importação e Exportação')"
     />
     <q-btn  
       icon="shopping_bag"
       icon-right
       size="lg"
       :color="mudaCorBotao('Marketing')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Marketing"
       @click="tipoServico('Marketing')"
     />
     <q-btn
       icon="event_note"
       icon-right
       size="lg"
       :color="mudaCorBotao('PCP')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="PCP"
       @click="tipoServico('PCP')"
     />
     <q-btn
       icon="local_shipping"
       icon-right
       size="lg"
       :color="mudaCorBotao('Logistica')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Logistica"
       @click="tipoServico('Logistica')"
     />
     <q-btn
       icon="account_box"
       icon-right
       size="lg"
       :color="mudaCorBotao('Gestão')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Gestão"
       @click="tipoServico('Gestão')"
     />
     <q-btn
       icon="person"
       icon-right
       size="lg"
       :color="mudaCorBotao('Clientes')"
       class="q-px-lg q-py-xs bordarbotoes"
       label="Clientes"
       @click="tipoServico('Clientes')"
     />
    </div>
    <div class="inputServicos">
    <p style="font-size:18px">Acima estão os principais modulos, dentro deles temos outros que abrange detalhadamente cada um, 
       queremos saber se precisa de algo mais específico.</p>
    <q-input
        outlined
        type="text"
        v-if="servicosOutros"
        v-model="textoServicos"
        label="Quais outros tipos de serviços ?"
      />
    </div>

       </q-step>
       
       
       <q-step
  :name="4"
  title="Localização"
  caption="Onde sua empresa está localizada."
  icon="person_pin_circle"
  :done="step > 4"
>
  <div class="q-pa-md">
   
    <div class="cep-container">
      <q-input
        outlined
        class="input-cep"
        style="width: 100%; max-width: 650px"
        v-model="cep"
        label="CEP"
        mask="#####-###"
        :loading="CEPLoading"
        @blur="onBuscaCep"
      />
      <q-btn @click="onBuscaCep" label="Buscar Endereço" color="primary" class="btn-cep"/>
    </div>

    <div v-if="endereco">
      <q-input
        outlined
        style="width: 100%; max-width: 650px"
        type="text"
        v-model="endereco"
        label="Endereço"
        class="margin-input"
      />
      <q-input
        outlined
        style="width: 100%; max-width: 650px"
        type="text"
        v-model="cidade.cidade"
        label="Cidade"
        class="margin-input"
      />
      <q-input
        outlined
        style="width: 100%; max-width: 650px"
        type="text"
        v-model="estado.estado"
        label="Estado"
        class="margin-input"
      />
      <q-input  
        outlined
        style="width: 100%; max-width: 650px"
        type="text"
        v-model="complemento"
        label="Complemento"
        class="margin-input"
      />
    </div>

    <div v-if="error" class="text-red">
      <h6>{{ error }}</h6>
    </div>
  </div>
</q-step>
  <q-step
    :name="5"
    title="Segmento"
    caption="Em que área sua empresa atua."
    icon="emoji_people"
    :done="step > 5"
  >
    <div class="negocio">
      <q-btn
        icon="construction"
        icon-right
        size="lg"
        :color="mudaCorBotao('Equipamentos e Serviços')"
        class="q-px-lg q-py-md justify-start"
        label="Equipamentos e Serviços"
        @click="tipoSegmento('Equipamentos e Serviços')"
      >
      </q-btn>

      <q-btn
        icon="engineering"
        icon-right
        size="lg"
        :color="mudaCorBotao('Indústrial')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Indústrial"
        @click="tipoSegmento('Indústrial')"
      />

      <q-btn
        icon="storefront"
        icon-right
        size="lg"
        :color="mudaCorBotao('Comércio Varejista')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Comércio Varejista"
        @click="tipoSegmento('Comércio Varejista')"
      />

      <q-btn
        icon="local_convenience_store"
        icon-right
        size="lg"
        :color="mudaCorBotao('Comércio Atacadista')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Comércio Atacadista"
        @click="tipoSegmento('Comércio Atacadista')"
      />

      <q-btn
        icon="chalet"
        icon-right
        size="lg"
        :color="mudaCorBotao('Turismo e Hotelaria')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Turismo e Hotelaria"
        @click="tipoSegmento('Turismo e Hotelaria')"
      />

      <q-btn
        icon="computer"
        icon-right
        size="lg"
        :color="mudaCorBotao('Tecnologia')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Tecnologia"
        @click="tipoSegmento('Tecnologia')"
      />

      <q-btn
        icon="hail"
        icon-right
        size="lg"
        :color="mudaCorBotao('Serviços Pessoais')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Serviços Pessoais"
        @click="tipoSegmento('Serviços Pessoais')"
      />

      <q-btn
        icon="account_balance"
        icon-right
        size="lg"
        :color="mudaCorBotao('Financeiro')"
        class="q-px-lg q-py-md justify-start bordarbotoes"
        label="Financeiro"
        @click="tipoSegmento('Financeiro')"
      />
    
    </div>
    
    <div class="q-pa-md">
      <p style= "font-size:18px">Para concluir, por favor informe o melhor horário, telefone e o nome da pessoa com quem podemos entrar em contato.</p>
    <div class="q-gutter-sm row inputs">
      
      <q-input outlined v-model="time" mask="##:##" label="Selecione o horário" :rules="[val => !!val || 'Selecione a hora']">
        <template v-slot:append>
          <q-icon name="access_time" class="cursor-pointer">
            <q-popup-proxy cover transition-show="scale" transition-hide="scale">
              <q-time v-model="time" format24h @input="salvarHora">
                <div class="row items-center justify-end">
                  <q-btn v-close-popup label="Fechar" color="primary" flat />
                </div>
              </q-time>
            </q-popup-proxy>
          </q-icon>
        </template>

      </q-input>
      <q-input outlined v-model="date" mask="##/##/####" label="Selecione a data" :rules="[val => !!val || 'Selecione a data']">
      <template v-slot:append>
        <q-icon name="event" class="cursor-pointer">
          <q-popup-proxy cover transition-show="scale" transition-hide="scale">
            <q-date v-model="date" mask="DD/MM/YYYY" @input="salvarDate">
              <div class="row items-center justify-end">
                <q-btn v-close-popup label="Fechar" color="primary" flat />
              </div>
            </q-date>
          </q-popup-proxy>
        </q-icon>
      </template>
    </q-input>
     
      <q-input
        outlined  
        type="text"
        v-model="numeroContato"
        mask="(##) #####-####"
        label="Numero para Contato"
        :rules="[val => val.toString().length === 15 || 'Este campo não pode ficar em branco']"
      />

      <q-input
        outlined
        type="text"
        v-model="nomeResponsavel"
        label="Nome para Contato"
        :rules=" [val => val.length > 0 || 'Esse campo não pode ficar em branco' ]"
      />

    </div>
  </div>
  </q-step>
  
      <template v-slot:navigation>
          <q-stepper-navigation >
           <q-btn @click="validateForm" color="primary" :label="step === 5 ? 'Enviar' : 'Continue'" />
           <q-btn v-if="step > 1" flat color="primary" @click="$refs.stepper.previous()" label="Voltar" />
         </q-stepper-navigation>
       </template>
     </q-stepper>
     <q-dialog v-model="popupConfirm" persistent>
      <q-card>
        <q-card-section class="row items-center">
          <q-avatar icon="check" color="positive" text-color="white" />
          <span class="margin1 text-h6 text-center">
            Solicitação enviada para análise
          </span>
          <span class="margin1">
            Retornaremos a solicitação pelo Numero de contato ou e-mail nos
            próximos dias.
          </span>
        </q-card-section>

        <q-card-actions align="right" class="margin1">
          <q-btn
            flat
            label="Fechar"
            color="primary"
            rounded
            v-close-popup
            @click="sair"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
  </div>
</template>
  
 <script>
 
 
 import Incluir from "../http/incluir_registro";
 import funcoesPadroes from "../http/funcoes-padroes";
 import notify from "devextreme/ui/notify";

 
 export default {
  
   data() {
     return {
       step: 1,
       nome: "",
       negocio: "",
       numeroCelular: "",
       email: "",
       cargo:"",
       mostraInputUser:false,
       mostraInputIndica:false,
       mostraInputGeral:false,
       textoIndicacao:"",
       apareceBotao: false,
       servicosOutros:true,
       textoServicos:"",
       checkboxNumbero:false,
       numeroContato:"",
       time: "",  
       horaSalva: "",  
       nomeResponsavel:"", 
       checkboxNome:false,
       cep: "", 
       endereco: "",
       cidade: "",
       estado: "",
       error: "",   
       complemento:"",   
       tiponegc: "", 
       tipoServ:"",
       popupConfirm: false,
       tpsegmento:"",
       messege:"",
       date:"",
       dataSalva:"",
       CEPLoading: false,
       api:"925/1435", //API REGISTRO NOVO USUARIO EGISNEt
       
     }
   },
   async created() {
    localStorage.cd_empresa = 3;
  },
   mounted() {},

   methods: {
   async validateForm() {     
      localStorage.cd_empresa = 0;
       this.formulario();    
       if(this.step === 1){
       if (this.formCerto) {
          this.$refs.stepper.next();  
        }
       }
      
      if (this.step === 2) {
      this.tipoNegocio();
      if (this.tiponegc) {
        this.$refs.stepper.next();
      } else{
        notify("Selecione um tipo de Negócio");
      }
    }

      this.tipoServico()
      if(this.step === 3){
      if(this.tipoServ){
        this.$refs.stepper.next()
      }else{
      notify("Selecione um tipo de Serviço");
  }  
    }
      
    this.onBuscaCep(); 
      if(this.step === 4){
      if (this.endereco !== "" &&
          this.cidade !== ""   &&
          this.estado !== "" 
        ) {
         this.$refs.stepper.next()
        }
       }     
       
      this.tipoSegmento();
      this.salvarHora();
      this.nomeRespon();
      this.numCelular();
      this.salvarDate();
      if (this.step === 5) {
        if (
          this.dataSalva !== "" &&
          this.tpsegmento &&
          this.horaSalva !== "" &&
          this.numeroContato.length === 15 &&
          this.nomeResponsavel.length > 0
        ) {
          localStorage.cd_empresa = 3;
          let objetoSalvaProcedure = {
            nome: this.nome,
            negocio: this.negocio,
            numero_celular: this.numeroCelular,
            email: this.email,
            cargo: this.cargo,
            texto_Indicacao: this.textoIndicacao,
            texto_servico: this.textoServicos,
            numero_contato: this.numeroContato,
            hora_salva: this.horaSalva,
            nome_responsavel: this.nomeResponsavel,
            cep: this.cep,
            endereco: this.endereco,
            cidade: this.cidade.cd_cidade,
            estado: this.estado.cd_estado,
            complemento: this.complemento,
            tipo_negocio: this.tiponegc,
            tipo_segmento: this.tpsegmento,
            tipo_servico: this.tipoServ,
            data_salva: this.dataSalva,
            
          };
          await Incluir.incluirRegistro(this.api, objetoSalvaProcedure);
          this.popupConfirm = true;
          
        
        }else {
            notify("Selecione um botão e preencha todos os campos")
        }
      }
    },
      formulario() {
        this.formCerto = this.nome.length > 0 && 
                         this.negocio.length > 0 && 
                         this.cargo.length > 0 && 
                         this.numeroCelular.length === 15 &&
                         this.email.length > 0 && /.+@.+\..+/.test(this.email);
                        },              

      tipoNegocio(negocios){
      if(negocios === "Redes e Franquias" || negocios === "Grande Empresa" || negocios === "Microempresa" || 
         negocios === "Pequena Empresa" || negocios === "Trabalho Sozinho"|| negocios === "Média Empresa"){
        this.tiponegc = negocios;
      }
      
    },
     onItemClick(tipos){
      if(tipos == "Instagram"){
        this.mostraInputUser = true
      }else{
        this.mostraInputUser = false
      }
      
      if (tipos == "Feiras" || tipos == "Outros" || tipos == "Pesquisa Google"){
          this.mostraInputGeral = true
      }else{
        this.mostraInputGeral = false
      } 
      
      if (tipos == "Vendedor" || tipos == "Indicação" ){
          this.mostraInputIndica = true

        }else{
          this.mostraInputIndica = false
        }
      },

    tipoServico(servicos){
     
      if(servicos === "Financeiro" || servicos === "PCP" || servicos === "Gestão" || servicos === "Logistica" ||
         servicos === "Clientes" ||servicos === "Compras" || servicos === "Controle de Estoque" || 
         servicos === "Contabilidade" || servicos === "Importação e Exportação"|| servicos === "Marketing"){
        
        this.tipoServ = servicos
     }
  
    },
    
    numCelular(){
      if(this.checkboxNumbero){
          this.numeroContato = this.numeroCelular
          
        }  
        },
  
    nomeRespon(){
      if(this.checkboxNome){
        this.nomeResponsavel = this.nome
       
      }
    },
    
 
      salvarHora() {
        this.horaSalva = this.time
    },
      
      salvarDate(){
        this.dataSalva = this.date
      },
    
      async onBuscaCep() {
        if (this.cep.length > 7) {
        try {
          this.CEPLoading = true;
          const response = await funcoesPadroes.buscaCep(this.cep)
          this.CEPLoading = false;
          if (response) {
            this.endereco = response[0].logradouro
            this.cidade = {cidade: response[0].localidade, cd_cidade:response[0].cd_cidade}    
            this.estado = {estado: response[0].nm_estado, cd_estado:response[0].cd_estado}
            this.error = ""
          } else{
            this.error = "CEP não encontrado."
            this.endereco = ""
            this.cidade = ""
            this.estado = ""
          }
        } catch (err) {
          this.error = "Erro ao buscar o CEP."
          this.endereco = ""
          this.cidade = ""
          this.estado = ""
        }
      } else {
        this.error = "Digite um CEP válido."
        this.endereco = ""
        this.cidade = ""
        this.estado = ""
      }
    },
    tipoSegmento(segmento){
      if(segmento === "Equipamentos e Serviços" || segmento === "Indústrial" ||segmento === "Comércio Varejista" || 
         segmento === "Comércio Atacadista" || segmento === "Turismo e Hotelaria" || 
         segmento ==="Tecnologia" || segmento === "Serviços Pessoais" || segmento === "Financeiro"){
          this.tpsegmento = segmento
	}
}, 
  
mudaCorBotao(valor) {
    if(this.tiponegc === valor){
      return "grey-7"
    }
    if (this.tipoServ === valor) {
      return "grey-7"
    }
    if (this.tpsegmento === valor){
      return "grey-7"
    }
    return "orange-9"
},
sair() {
      window.location.assign("https://egisnet.com.br/")
    },
  
  
  }
  } 

 
 </script>
 
  <style>
   
  .tela {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    width: 100vw;
    padding: 15px;
    background-color: white;
  }

  .stepper-container {
    width: 95vw;
    height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    margin-top:40px;
  }

  .imagem {
    position: absolute;
    top: 10px;
    right: 2%;
    max-width: 100%;
    height: auto;
    margin: auto;
  }

  .formulario {
    width: 350px;
    margin-bottom: 25px;
  }

  .negocio {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 30px;
    margin-top: 50px;
    padding: 20px;
  }
/*
  .input_step1{
   margin-bottom:10%; 
 }
*/
  .checkboxform {
    display: flex;
    align-items: center;
    gap: 10px;
   
  }

  .negocio .q-btn {
    flex: 0 0 48%;
    margin-bottom: 10px;
  }

  .inputbotoes {
    width: 30%;
    margin-top: 20px;
  }

  .servicos {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 10px;
    margin-top: 20px;
  }

  .servicos .q-btn {
    flex: 0 0 48%;
    margin-bottom: 10px;
  }

  #indicacao {
    margin: 20px;
  }

  .cep-container {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 20px;
  }

  .input-cep {
    flex: 1;
  }

  .btn-cep {
    width: 180px;
  }

  .margin-input {
    margin-bottom: 15px;
  }

  .text-red h6 {
    color: red;
    font-weight: bold;
  }

  .bordarbotoes {
    border: solid 1px rgb(170, 170, 170);
    border-radius: 10px;
  }
  .q-px-lg{
    background-color:#EF6C00;
    transition: background-color 0.5s ease;
    color: white;
  }
  .q-px-lg:hover{
    background-color: rgb(250, 250, 250);
    color: black;
  }
  .inputs {
    display:flex;
    gap:10px;
   
  }
  
  @media (max-width: 768px) {
    .stepper-container {
      width: 90vw;
      height: auto;
    }

    .negocio {
      flex-direction: column;
      gap: 20px;
      margin-top: 30px;
      width:50px;
    }

    .negocio .q-btn,
    .servicos .q-btn {
      flex: 1;
      margin-bottom: 10px;
    }

    .inputbotoes {
      width: 100%;
    }

    .imagem {
      position: relative;
      top: 0;
      right: 0;
      max-width: 80%;
      margin: 0 auto;
    }

    .formulario {
      width: 100%;
    }

    .cep-container {
      flex-direction: column;
      align-items: flex-start;
    }

    .btn-cep {
      width: 100%;
    }
.selected {
    background-color: #027be3; /* Estilo para o botão selecionado */
  color: white;
  }
  }
  @media (max-width: 480px) {
    .stepper-container {
      width: 100vw;
      padding: 10px;
    }

    .negocio,
    .servicos {
      flex-direction: column;
    }

    .imagem {
      max-width: 50%;
    }

    .cep-container {
      flex-direction: column;
      gap: 5px;
    }
    
    .checkboxform {
      flex-direction: column;
      align-items: flex-start;
    }

    .bordarbotoes {
      width: 100%;
      
    }
    .margin-input{
      width: 450vh;
    }
  }
</style>

