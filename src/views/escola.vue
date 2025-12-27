<template>

<form action="/pagina-processa-dados-do-form" method="post">


<br>
<div>
        <h2 class="borda-bloco">Escola</h2>

<br>      
    </div>
<div class="row">    
<div class="col-sm-6">
        
        <q-input v-model="nm_escola" label="Escola" >
        <template v-slot:prepend>
          <q-icon name="school" />
        </template>
      </q-input>

</div>
<div class="col-sm-6">

        <q-input v-model="email" label="E-mail"  >
           <template v-slot:prepend>
          <q-icon name="email" />
        </template>
      </q-input>
    </div>
</div>    
<div class="row">
    <div class="col-sm-6">
    
       <q-input  v-model="cd_celular" label="Celular" mask="(##)#####-####">
   <template v-slot:prepend>
          <q-icon name="smartphone" />
        </template>
      </q-input>
    </div>

    <div class="col-sm-6">

       <q-input  v-model="cd_telefone" label="Telefone"  mask="(##)####-####">
<template v-slot:prepend>
          <q-icon name="phone" />
        </template>
      </q-input>
    </div>
    </div>
    <div>

        <q-input  v-model="cd_cnpj" label="CNPJ" mask="##.###.###/####-##">
<template v-slot:prepend>
          <q-icon name="business" />
        </template>
      </q-input>
    </div>
<div class="row">
    <div class="col-sm-2">
        <q-input  v-model="cd_cep" label="CEP" mask="#####-###" >
<template v-slot:prepend>
          <q-icon name="map" />
        </template>
      </q-input>
    </div>

    <div class="col-sm-5">
        <q-input  v-model="nm_endereco" label="Endereço" >
<template v-slot:prepend>
          <q-icon name="home" />
        </template>
      </q-input>
    </div>

    <div class="col-sm-1">
        <q-input  v-model="cd_numero" label="Nº" >
<template v-slot:prepend>
          <q-icon name="pin" />
        </template>
      </q-input>
    </div>

    <div class="col-sm-2">

        <q-input  v-model="nm_bairro" label="Bairro" >
<template v-slot:prepend>
          <q-icon name="location_searching" />
        </template>
      </q-input>
    </div>

    <div class="col-sm-4">
        
        <q-input  v-model="nm_cidade" label="Cidade" >
<template v-slot:prepend>
          <q-icon name="location_city" />
        </template>
      </q-input>
    </div>

    <div>
        
        <q-input  v-model="sg_estado" label="Estado" mask="AA">
<template v-slot:prepend>
          <q-icon name="flag" />
        </template>
      </q-input>
    </div>
    </div>
  

         <br>
    <div class="button">
        
        <q-btn no-caps color="primary" label="Salvar" />
        
    </div>

</form>
</template>

<script>
export default {

}
</script>

<style>
 .borda-bloco{
        border: solid 1 px rgb(170,170,170);
        border-radius: 10px;
        background:rgb(230, 230, 230);
    }
.borda-bloco {
    color: rgb(230, 86, 42);
    padding: 10px;
    
}
.q-input {
border-width: medium;
border-style: none;
border-color: rgb(4, 0, 0);
    }
.q-input{
  border: solid 1 px rgb(170,170,170);
  border-radius: 5px;
  background:rgb(230, 230, 230);
  margin: 5px;
}

.borda-bloco{
  border: 2px solid rgb(201, 194, 194);
  border-radius: 10px;
}



</style>