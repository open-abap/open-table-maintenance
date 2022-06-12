/* eslint-disable @typescript-eslint/no-require-imports */
/* eslint-disable @typescript-eslint/no-var-requires */
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const webpack = require("webpack");

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
    clean: true,
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
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "test/index.html",
    }),
    new CopyPlugin({
      patterns: [
        { from: './node_modules/sql.js/dist/sql-wasm.wasm', to: "./" },
      ],
    }),
    new webpack.ProvidePlugin({
      Buffer: ['buffer', 'Buffer'],
    }),
  ],
});
