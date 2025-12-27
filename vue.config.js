module.exports = {
  publicPath: '/',

  pwa: {
    name: 'EgisNet',
  },

  pluginOptions: {
    quasar: {
      importStrategy: 'kebab',
      rtlSupport: true,
    },
  },

  transpileDependencies: ['quasar'],

  devServer: {
    proxy: {
      '^/api': {
        target: 'https://egiserp.com.br', // destino real
        //target: '192.168.100.104', // destino real

        changeOrigin: true, // finge ser o host de destino
        secure: false, // aceita https com self-signed/variações
        logLevel: 'debug', // útil pra ver os logs no terminal
        pathRewrite: { '^/api': '/api' },
        onProxyReq(proxyReq, req, res) {
          const xbanco = req.headers['x-banco'];

          if (xbanco) proxyReq.setHeader('x-banco', xbanco);

          const auth = req.headers['authorization'];
          if (auth) proxyReq.setHeader('authorization', auth);

          //

          //if (req.headers['x-banco']) {
          //  proxyReq.setHeader('x-banco', req.headers['x-banco']);
          //}
          // Remova cabeçalhos que quebram preflight
          //proxyReq.removeHeader('x-banco');
        },
        //cookieDomainRewrite: 'localhost',

        '^/erp': {
          target: 'https://egiserp.com.br',
          changeOrigin: true,
          secure: false,
          pathRewrite: { '^/erp': '/api' },
        },
        '^/net': {
          target: 'https://egisnet.com.br',
          changeOrigin: true,
          secure: false,
          pathRewrite: { '^/net': '/api' },
        },

        // sem pathRewrite porque já chamamos /api/...
      },
      // Se tiver outros endpoints (ex.: /upload, /files), adicione aqui.
      // '/upload': { target: 'https://egiserp.com.br', changeOrigin: true, secure: false }
    },
  },
};
