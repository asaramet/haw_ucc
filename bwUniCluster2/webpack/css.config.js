const path = require('path');

const nodePath = path.resolve(__dirname, '../node_modules');
const srcPath = path.resolve(__dirname, '../src');
const configPath = path.resolve(__dirname, '../webpack');

//console.log("srcPath: ", srcPath);

module.exports = {
  mode: 'production',
  entry: ['./aot_files/styles.scss'],
  output: {
    path: path.resolve(__dirname, '../src'),
    //filename: 'styles.css'
  },
  module : {
    rules: [
      {
        test: /\.scss$/,
        exclude: [nodePath, srcPath, configPath],
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].css'
            }
          },
          'extract-loader',
          'css-loader',
          'sass-loader'
        ]
      }
    ]
  },
  plugins: []
};
