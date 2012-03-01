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

fs     = require 'fs'
path   = require 'path'
events = require 'events'
util   = require 'util'
crypto = require 'crypto'

utils      = require '../utils'
FileSet    = require '../FileSet'
Properties = require '../Properties'

#-------------------------------------------------------------------------------
module.exports = class Processor extends events.EventEmitter

    #---------------------------------------------------------------------------
    constructor: (@iDir, @oDir, @options) ->
        @records = []
    
    #---------------------------------------------------------------------------
    process: ->
        @iDirFull = path.resolve @iDir
        @oDirFull = path.resolve @oDir

#        console.log "iDir:    #{@iDir} #{@iDirFull}"
#        console.log "oDir:    #{@oDir} #{@oDirFull}"
#        console.log "options: #{JSON.stringify(@options)}"
#        console.log ""
        
        if !path.existsSync @iDirFull
            @emitErrorMessage "input directory '#{@iDir}' does not exist"
            return
        
        if !path.existsSync @oDirFull
            @emitErrorMessage "output directory '#{@oDir}' does not exist"
            return
        
        iStats = fs.statSync @iDirFull
        oStats = fs.statSync @oDirFull
        
        if !iStats.isDirectory()
            @emitErrorMessage "input directory '#{@iDir}' is not a directory"
            return
            
        if !oStats.isDirectory()
            @emitErrorMessage "output directory '#{@oDir}' is not a directory"
            return

        if @iDirFull == @oDirFull            
            @emitErrorMessage "the input and output directory cannot be the same"
            return
        
        config = @readConfig()
        
        config.name ||= 'no title provided'
        
        mainHtml = config['main.html'] || 'main.html'
        mainCss  = config['main.css']  || 'main.css'
        mainJs   = config['main.js']   || 'main.js'
        
        mainHtml   = utils.readFile(path.join(@iDir, mainHtml))
        mainHtml ||= '<!-- no HTML provided -->'
        
        mainCss    = utils.readFile(path.join(@iDir, mainCss))
        mainCss  ||= '/* no CSS provided */'
        
        mainJs     = utils.readFile(path.join(@iDir, mainJs))
        mainJs   ||= '/* no JavaScript provided */'
        
        config['main.html'] = mainHtml
        config['main.css']  = mainCss
        config['main.js']   = mainJs

        @emptyDir(@oDirFull)
        
        @writeIndexHtml(config)
        @writeIndexManifest(config)
        @writeHtAccess(config)
        
#        @checkForMain @iDirFull
        
        
#        iFileSet = FileSet.fromDir(@iDirFull)
#        oFileSet = FileSet.fromDir(@oDirFull)
        
#        console.log "iDir files:"
#        iFileSet.dump()
#        console.log ""
        
#        console.log "oDir files:"
#        oFileSet.dump()

#        @copyFiles(@oDirFull, @iDirFull, @)
        
#        manifest = path.join(@oDirFull, 'offl-site.manifest.txt')
#        contents = JSON.stringify(@records, null, 4)
#        fs.writeFileSync manifest, contents
        
#        manifest = path.join(@oDir, path.basename(manifest))
#        utils.logVerbose "created: #{manifest}"

        utils.log "shell created in: #{@oDir}"
        
        @emit 'done'

    #---------------------------------------------------------------------------
    writeIndexHtml: (config) ->
    
# <link rel="apple-touch-icon" sizes="72x72" href="touch-icon-ipad.png" />
# <meta name="apple-mobile-web-app-capable" content="yes" />
# <meta name="apple-mobile-web-app-status-bar-style" content="black" />
# <meta name="viewport" content="user-scalable=no, initial-scale=1.0, width=device-width">
# <meta name="format-detection" content="telephone=no">

        index = path.join(@oDirFull, 'index.html')
        return if path.existsSync(index)
        
        contents = []
        
        contents.push '<html manifest="index.manifest">'
        contents.push '<head>'
        contents.push "<title>#{config.name}</title>"
        
        if config['status-bar-style']
            contents.push '<meta name="apple-mobile-web-app-status-bar-style" content="' + config['status-bar-style'] + '" />'
        
        contents.push '<meta name="apple-mobile-web-app-capable" content="yes" />'
        
        vpUserScalable = config['viewport-user-scalable']        
        vpInitialScale = config['viewport-initial-scale']
        vpDeviceWidth  = config['viewport-device-width']
        
        viewPortParts = []
        viewPortParts.push "user-scalable=#{vpUserScalable}" if vpUserScalable
        viewPortParts.push "initial-scale=#{vpInitialScale}" if vpInitialScale
        viewPortParts.push "width=#{vpDeviceWidth}"          if vpDeviceWidth
        
        if viewPortParts.length
            vpContent = viewPortParts.join(', ')
            contents.push '<meta name="viewport" content="' + vpContent + '"" />'
        
        contents.push '<style>'
        contents.push config['main.css']
        contents.push '</style>'
        contents.push '<script>'
        contents.push config['main.js']
        contents.push '</script>'
        contents.push '</head>'
        contents.push '<body>'
        contents.push config['main.html']
        contents.push '</body>'
        contents.push '</html>'
        
        contents = contents.join '\n'
        
        fs.writeFileSync index, contents
        utils.logVerbose "created: #{index}"
    
    #---------------------------------------------------------------------------
    writeIndexManifest: () ->
        manifest = path.join(@oDirFull, 'index.manifest')
        return if path.existsSync(manifest)
        
        contents = """
            CACHE MANIFEST
            
            #----------------------------------------------------------
            CACHE:
            
            #----------------------------------------------------------
            NETWORK:
            *

            #----------------------------------------------------------
            # updated: #{new Date().toString()}
            #----------------------------------------------------------
        """
        
        fs.writeFileSync manifest, contents
        utils.logVerbose "created: #{manifest}"
        

    #---------------------------------------------------------------------------
    writeHtAccess: ->
        htAccess = path.join(@oDirFull, '.htaccess')
        return if path.existsSync(htAccess)

        contents = """
            # set content type for manifest
            AddType text/cache-manifest .manifest
        """

        fs.writeFileSync htAccess, contents
        utils.logVerbose "created: #{htAccess}"
        

    #---------------------------------------------------------------------------
    readConfig: () ->
        configFile = path.join(@iDir, 'config.properties')
        if !path.existsSync configFile
            @emitErrorMessage "a config.properties file was not found in #{@iDir}"
            return
            
        # console.log "config: #{JSON.stringify(@config,null,4)}"
        
        Properties.fromFile configFile

    #---------------------------------------------------------------------------
    emptyDir: (dir) ->
        fileSet = FileSet.fromDir(dir)
        
        for file in fileSet.fullFiles()
            utils.logVerbose "erased:  #{file}"
            fs.unlinkSync file
    
        
        for dir in fileSet.fullDirs().reverse()
            utils.logVerbose "rmdir:   #{dir}"
            fs.rmdirSync dir

    #---------------------------------------------------------------------------
    emitErrorMessage: (message) ->
        @emit 'error', new Error(message)

