const path = require('path');

const CompressionPlugin = require('compression-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const NgTools = require('@ngtools/webpack');

const nodePath = path.resolve(__dirname, '../node_modules');
const aotToolsPath = path.resolve(__dirname, '../aot_files');
const configPath = path.resolve(__dirname, '../webpack');

module.exports =  {
  mode: "production",
  entry: [
    './public/aot/src/main.aot.js'
  ],

  output: {
    // change the output path from frontend to frontend/public/js/app
    path: path.resolve(__dirname, '../public/js'),
    publicPath: "./js/",
    filename: '[name].bundle.js',
    chunkFilename: '[id].chunk.js'
  },

  module: {
    rules: [
      {
        //test: /(?:\.ngfactory\.js|\.ngstyle\.js|\.ts)$/,
        test: /\.ts$/,
        loader: '@ngtools/webpack'
      },
      {
        test: /\.html$/,
        loader: 'html-loader'
      }
    ]
  },

  resolve: {
    extensions: ['.js']
  },

  optimization: {
    minimizer: [
      new UglifyJsPlugin({
        cache: true,
      })
    ]
  },
  plugins: [
    new NgTools.AngularCompilerPlugin({
      tsConfigPath: './tsconfig-prod-aot.json',
      entryModule: './src/app/app.module#AppModule',
      sourceMap: false
    }),
    new CompressionPlugin({
      test: /\.js$/,
      exclude: [nodePath, aotToolsPath, configPath],
      filename: '[path].gz[query]',
      algorithm: 'gzip',
      threshold: 10240,
      minRatio: 0.8
    })
  ]
};
