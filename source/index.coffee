cluster= require 'cluster'
os= require 'os'

fs= require 'fs'
Log= require 'log'

manifest= require './package.json'
cfg= manifest.config
log= new Log 'main', fs.createWriteStream cfg.logfile

###

Инициализация кластера

Запускает воркеры по количеству процессоров.

###
if cluster.isMaster
    express= require 'express'
    app= express()
    app.use express.logger 'dev'
    app.use express.static "#{__dirname}/node/views/assets"
    app.use express.static "#{__dirname}/node/views/templates/Console"
    nWorkers= (do os.cpus).length
    for i in [1..nWorkers]
        worker= do cluster.fork

###

Инициализация воркера

###
if cluster.isWorker

    domain= require 'domain'
    d= do domain.create

    d.run ->
        App= require './node/index'
        app= App manifest, 'development'

        cfg= app.get 'config'

        srv= app.get 'server'
        srv.listen cfg.port, ->
            console.log "application listening on #{cfg.port}, worker #{cluster.worker.id}"
