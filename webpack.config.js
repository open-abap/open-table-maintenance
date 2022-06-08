/* eslint-disable @typescript-eslint/no-require-imports */
/* eslint-disable @typescript-eslint/no-var-requires */
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = ({mode} = {mode: "development"}) => ({
  entry: {
    "app": "./test/web.mjs",
  },
  mode,
  experiments: {
    topLevelAwait: true
  },
  output: {
    path: path.join(__dirname, "build"),
    filename: "[name].bundle.js",
    globalObject: "self",
  },
  devServer: {
    open: true,
    hot: true,
  },
  resolve: {
    fallback: {
      "./%23ui2%23cl_json.clas.mjs": false,
      "crypto": require.resolve("crypto-browserify"),
      "path": require.resolve("path-browserify"),
      "buffer": require.resolve("buffer/"),
      "zlib": false,
      "stream": false,
      "http": false,
      "fs": false,
      "https": false,
      "net": false,
    },
    extensions: [".mjs", ".js"],
  },
  module: {
    rules: [
      /*
      {
        test: /.m?js$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
      }
      */
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "test/index.html",
    }),
  ],
});
