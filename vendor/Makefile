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

#-------------------------------------------------------------------------------
update:
	-rm *.js
	-rm -rf bootstrap

	curl -# -o jquery.js        http://code.jquery.com/jquery-1.7.1.js
	curl -# -o underscore.js    https://raw.github.com/documentcloud/underscore/1.3.1/underscore.js
	curl -# -o backbone.js      https://raw.github.com/documentcloud/backbone/0.9.1/backbone.js
	curl -# -o showdown.js      https://raw.github.com/coreyti/showdown/master/src/showdown.js
	curl -# -o modjewel.js      https://raw.github.com/pmuellr/modjewel/1.2.1/modjewel-require.js
	curl -# -o WebSQLStepper.js https://raw.github.com/pmuellr/WebSQLStepper/master/WebSQLStepper.js
	curl -# -o mustache.js      https://raw.github.com/janl/mustache.js/0.4.0/mustache.js

	curl -# -o bootstrap.zip    http://twitter.github.com/bootstrap/assets/bootstrap.zip
	unzip bootstrap.zip
	rm bootstrap.zip