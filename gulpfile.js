const path = require('path')

const gulp = require('gulp')
const watch = require('gulp-watch')
const batch = require('gulp-batch')
const plumber = require('gulp-plumber')
const bs = require('browser-sync').create()
const wp = require('webpack-stream')
const webpack = require('webpack')
const ExtractTextPlugin = require('extract-text-webpack-plugin')

const sass = require('gulp-sass')
const precss = require('precss')
const cssnext = require('cssnext')
const postcss = require('gulp-postcss')
const cssnano = require('cssnano')
const autoprefixer = require('autoprefixer')

const jsPath = path.resolve(__dirname, 'app', 'assets', 'javascripts', 'v1')
const viewPath = path.resolve(__dirname, 'app', 'views', 'v1')
const scssPath = path.resolve(__dirname, 'app', 'assets', 'stylesheets', 'v1')

const mainJs = path.resolve(jsPath, 'app.js')
const mainScss = path.resolve(scssPath, 'app.scss')

const viewWatchPath = [
  path.resolve(viewPath, '*.html.erb'),
  path.resolve(viewPath, '**', '*.html.erb'),
  path.resolve(viewPath, '**', '**', '*.html.erb')
]
const scssWatchPath = [
  path.resolve(scssPath, '*.scss'),
  path.resolve(scssPath, '**', '*.scss')
]
const jsWatchPath = [
  path.resolve(jsPath, '*.js'),
]

const scssDistPath = path.resolve(__dirname, 'public', 'css')
const jsDistPath = path.resolve(__dirname, 'public', 'js')

gulp.task('css', function () {
  const processors = [
    autoprefixer,
    cssnano,
    cssnext,
    precss
  ]

  return gulp.src(mainScss)
    .pipe(sass().on('error', sass.logError))
    .pipe(postcss(processors))
    .pipe(gulp.dest(scssDistPath))
    .pipe(bs.stream())
})

gulp.task('js', function (cb) {
  const wpConfig = {
    entry: ['whatwg-fetch', mainJs],
    output: { path: jsDistPath, filename: 'app.js' },
    plugins: [
      new webpack.optimize.UglifyJsPlugin({ compress: { warnings: false } }),
      new ExtractTextPlugin(path.resolve(scssDistPath, 'bundle.css'))
    ],
    module: {
      loaders: [
        {
          test: /\.css$/,
          loader: ExtractTextPlugin.extract('style-loader', 'css-loader')
        }
      ]
    }
  }

  return gulp.src(mainJs)
    .pipe(plumber())
    .pipe(wp(wpConfig))
    .pipe(gulp.dest(jsDistPath))
})

gulp.task('watch', function () {
  watch(scssWatchPath, batch(function (events, done) {
    gulp.start('css', done);
  }));
  watch(jsWatchPath, batch(function (events, done) {
    gulp.start('js-reload', done);
  }));
  watch(viewWatchPath, batch(function (events, done) {
    bs.reload()
    done()
  }));
})

gulp.task('js-reload', ['js'], function (done) {
  bs.reload()
  done()
})

gulp.task('bs', function () {
  bs.init({
    proxy: 'localhost:3000'
  })
})

gulp.task('default', ['css', 'js', 'watch', 'bs'])
