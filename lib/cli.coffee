#-------------------------------------------------------------------------------
# Copyright (c) 2012 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------

fs         = require 'fs'
path       = require 'path'

nopt       = require 'nopt'
uglify     = require 'uglify-js'

utils      = require './utils'
Processor  = require './Processor'
stackTrace = require './stackTrace'

#-------------------------------------------------------------------------------
class CLI

    #---------------------------------------------------------------------------
    constructor: ->
        @argv = []
        @opts = {}


    #---------------------------------------------------------------------------
    run: ->
    
        opts = 
            debug:   Boolean
            verbose: Boolean
            version: Boolean
            help:    Boolean

        shortOpts = 
            d:   ["--debug"]
            v:   ["--verbose"]
            V:   ["--version"]
            h:   ["--help"]
            '?': ["--help"]

        parsed = nopt(opts, shortOpts, process.argv, 2)

        @argv = parsed.argv.remain
        @opts = 
            debug:   parsed.debug
            verbose: parsed.verbose
            version: parsed.version
            help:    parsed.help
        
        #console.log "argv: #{JSON.stringify(@argv)}"
        #console.log "opts: #{JSON.stringify(@opts)}"
        
        if @opts.help
            @help()
            return
            
        if @opts.version
            console.log utils.VERSION
            return

        utils.setVerbose @opts.verbose
        
        if @argv.length != 2
            utils.error 'an input and an output directory must be specified'
        
        [iDir, oDir] = @argv
        
        processor = new Processor(iDir, oDir, @opts)
        
        processor.addListener 'done', ->
            process.exit()

        processor.addListener 'error', (e) ->
            utils.error e.message
        
        processor.process()
    
    #---------------------------------------------------------------------------
    help: ->
        console.log "#{utils.PROGRAM} [options] inDir outDir"
        console.log ''
        console.log 'builds an offline-able site from inDir into outDir'
        console.log ''
        console.log 'options:'
        console.log '  -d --debug     generate debuggable output'
        console.log '  -v --verbose   noisy'
        console.log '  -V --version   display version'
        console.log '  -h --help      display this help'
    
#-------------------------------------------------------------------------------
module.exports = new CLI