// following http://www.htmlwidgets.org/develop_intro.html
"use strict";

var sbgnviz = require('sbgnviz');
var filesaverjs = require('filesaverjs');
var cytoscape = require('cytoscape');
var jQuery = require('jquery');
var tippy = require('tippy.js');

// Get cy extension instances
var cyPanzoom = require('cytoscape-panzoom');
var cyEdgeBendEditing = require('cytoscape-edge-bend-editing');

// Options
var options = {
    networkContainerSelector: '#sbgnvizShiny',
    //Necessary?
    imgPath: '',
    // whether to fit label to nodes
    fitLabelsToNodes: function () {
        return true;
    },
    // Whether to fit labels to a node's info boxes
    fitLabelsToInfoboxes: function () {
      return true;
    },
    // dynamic label size it may be 'small', 'regular', 'large'
    dynamicLabelSize: function () {
        return 'regular';
    },
    // percentage used to calculate compound paddings
    compoundPadding: function () {
        return 10;
    },
    // From https://github.com/iVis-at-Bilkent/cytoscape.js-expand-collapse
    rearrangeAfterExpandCollapse: function () {
        return false;
    },
    // Whether to animate on drawing changes
    animateOnDrawingChanges: function () {
        return false;
    },
    undoable: false
};

// Register cy extensions 
cyEdgeBendEditing(cytoscape, jQuery);
cyPanzoom(cytoscape, jQuery);

// Libraries to pass sbgnviz
var libs = {
    cytoscape: cytoscape,
    jQuery: jQuery,
    filesaverjs: filesaverjs,
    tippy: tippy
};

// Register libs
sbgnviz.register(libs);

var sbgnmlText = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><sbgn xmlns="http://sbgn.org/libsbgn/0.2"><map language="process description"><glyph class="submap" id="entityVertex_167060_649"><label text="Empty Map"/><bbox w="131.0" h="46.0" x="0.0" y="0.0"/></glyph></map></sbgn>';

console.log('START');

// apparently two version of jquery loaded: by shiny, and just above
// see https://api.jquery.com/jquery.noconflict/ and
// this stackoverflow discussion: https://stackoverflow.com/questions/31227844/typeerror-datatable-is-not-a-function
jQuery.noConflict();

HTMLWidgets.widget({
  name: 'sbgnvizShiny',
  type: 'output',
  factory: function(el, width, height) {
    console.log("---- entering factory, initial dimensions: " + width + ", " + height);

    var sbgnvizInstance = sbgnviz(options);

    return {
      renderValue: function(x) {
        console.log("x: " + JSON.stringify(x));
        if(x.sbgnml != "") {
          sbgnmlText = x.sbgnml;
        }
        
        jQuery("#save-as-svg").one('click', function(evt) {
          console.log("saveSVGtoFile");
          sbgnvizInstance.saveAsSvg("network.svg");
        });
        
        jQuery("#save-as-png").one('click', function(evt) {
          console.log("savePNGtoFile");
          sbgnvizInstance.saveAsPng("network.png");
        });
        
        sbgnvizInstance.loadSBGNMLText(sbgnmlText);
      }
    } // return
  } // factory
})

/*
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("savePNGtoFile", function(message){
   console.log("savePNGtoFile: " + message);
   var pngJSON = JSON.stringify(window.cyj.png({scale: 3, full: true}));
   console.log("png: " + pngJSON);
   Shiny.setInputValue("pngData", pngJSON, {priority: "event"});
})
*/
