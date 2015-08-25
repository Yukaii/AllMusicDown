var path = require('path');
var node_modules = path.resolve(__dirname, 'node_modules');
var pathToReact = path.resolve(node_modules, 'react/dist/react.min.js');


module.exports = {
  entry: {
    js: [path.resolve(__dirname, 'src/javascripts/main.js')],
    html: [path.resolve(__dirname, 'views/index.html')]
  },
  resolve: {
    alias: {
      'react': pathToReact
    }
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'main.js',
  },
  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        loader: 'babel'
      },
      {
        test: /\.html$/,
        loader: "file?name=[name].[ext]",
      },
    ],
    noParse: [pathToReact]
  },
  devServer: {
      contentBase: "./dist",
      // hot: true,
      // inline: true,
      colors: true,
      progress: true,
      devtool: 'eval'
      // publicPath: path.join(__dirname, 'dist')
  },
  private: true
};
