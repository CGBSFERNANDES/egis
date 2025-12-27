module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
    es6: true,
  },
  parserOptions: {
    parser: "babel-eslint",
    sourceType: "module",
  },
  extends: [
    "plugin:vue/essential", // Regras essenciais do Vue 2
    "eslint:recommended",   // Regras básicas do ESLint
  ],
  rules: {
    // Adicione ou altere regras aqui
    "no-console": "off", // Permite console.log
    "semi": ["error", "always"], // Exige ponto e vírgula
    "quotes": ["error", "double"], // Exige aspas duplas
    "vue/no-unused-components": "warn", // Apenas avisa sobre componentes não usados
    "no-debugger": "off",
    "vue/no-mutating-props": "off",
    "vue/multi-word-component-names": "off",
    "vue/require-default-prop": "off",
    "vue/attribute-hyphenation": "off",
  },
};