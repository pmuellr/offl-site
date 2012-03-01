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

fs = require 'fs'

utils = require './utils'

module.exports = class Properties

    #---------------------------------------------------------------------------
    @fromFile: (fileName) ->
        contents = fs.readFileSync(fileName, 'utf-8')
        
        result = {}
        
        lines = contents.split /\n/
        for line in lines
            line = utils.trim line
            continue if line.match /^#/ 
            continue if line.match /^\/\// 
            continue if line.match /^\/\*/ 
            
            match = line.match /(.*?)\s*[:=]\s*(.*)/
            continue if !match
            
            key = utils.trim match[1]
            val = utils.trim match[2]
            
            result[key] = val
        
        result
