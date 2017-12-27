module.exports = {
    entry: './src/app.js',
    output: {
      filename: './dist/bundle.js'
    },
    module: {
        rules: [{
            test: /\.css$/,
            use: ['style-loader', 'css-loader']
          },
          {
            test: /\.scss$/,
            use: [{
              loader: "style-loader" // creates style nodes from JS strings
            }, {
              loader: "css-loader" // translates CSS into CommonJS
            }, {
              loader: "sass-loader" // compiles Sass to CSS
            }]
          }
        ]
    },
    devServer: {
      host: '0.0.0.0'
    }
};