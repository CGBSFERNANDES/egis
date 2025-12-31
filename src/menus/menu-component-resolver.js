// src/menus/menu-component-resolver.js

const wrappers = require.context("@/menus", false, /^\.\/my_\d+\.vue$/);

export function resolveMenuContent(cd_menu, nm_caminho_componente) {
  const id = Number(cd_menu) || 0;
  const wrapperFile = `./my_${id}.vue`;

 // if (wrappers.keys().includes(wrapperFile)) {
    //return () => wrappers(wrapperFile);
 // }

  console.log('dados para rota --> ', cd_menu, nm_caminho_componente)


  return () =>
    import(
      /* webpackChunkName: "display-data" */ `@/views/${nm_caminho_componente}`
    );
}
