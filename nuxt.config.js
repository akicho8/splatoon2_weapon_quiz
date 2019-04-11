import pkg from './package'

export default {
  mode: 'spa',

  /*
  ** Headers of the page
  */
  head: {
    title: pkg.name,
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: pkg.description }
    ],
    link: [
      // { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
    ]
  },

  /*
  ** Customize the progress-bar color
  */
  loading: { color: '#fff' },

  /*
  ** Global CSS
  */
  css: [
    '~/assets/scss/app.scss',
  ],

  /*
  ** Plugins to load before mounting the App
  */
  plugins: [
  ],

  /*
  ** Nuxt.js modules
  */
  modules: [
    // Doc: https://buefy.github.io/#/documentation
    // 'nuxt-buefy',

    ['nuxt-buefy', {
      css: false,
      // materialDesignIcons: false
    }],

  ],

  /*
  ** Build configuration
  */
  build: {
    /*
    ** You can extend webpack config here
    */
    extend(config, ctx) {
      // https://qiita.com/dorarep/items/b9783ea6cd18308a06a0
      config.module.rules.push({
        test: /\.(ogg|mp3|wav|mpe?g)$/i,
        use: 'file-loader',
        exclude: /(node_modules)/,
      })
    }
  },

  // サブディレクトリへのデプロイ対応 https://ja.nuxtjs.org/api/configuration-router/
  router: {
    base: process.env.NODE_ENV === 'production' ? "/sp2quiz/" : "/",
  },
}
