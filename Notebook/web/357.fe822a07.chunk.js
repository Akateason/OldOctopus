(window.webpackJsonp=window.webpackJsonp||[]).push([[357],{608:function(e,n){!function(e,n){"undefined"!==typeof e&&e.Prism&&e.document&&n.createRange&&(Prism.plugins.KeepMarkup=!0,Prism.hooks.add("before-highlight",function(e){if(e.element.children.length){var n=0,o=[];!function e(t,d){var a={};d||(a.clone=t.cloneNode(!1),a.posOpen=n,o.push(a));for(var r=0,s=t.childNodes.length;r<s;r++){var p=t.childNodes[r];1===p.nodeType?e(p):3===p.nodeType&&(n+=p.data.length)}d||(a.posClose=n)}(e.element,!0),o&&o.length&&(e.keepMarkup=o)}}),Prism.hooks.add("after-highlight",function(e){if(e.keepMarkup&&e.keepMarkup.length){e.keepMarkup.forEach(function(o){!function e(o,t){for(var d=0,a=o.childNodes.length;d<a;d++){var r=o.childNodes[d];if(1===r.nodeType){if(!e(r,t))return!1}else 3===r.nodeType&&(!t.nodeStart&&t.pos+r.data.length>t.node.posOpen&&(t.nodeStart=r,t.nodeStartPos=t.node.posOpen-t.pos),t.nodeStart&&t.pos+r.data.length>=t.node.posClose&&(t.nodeEnd=r,t.nodeEndPos=t.node.posClose-t.pos),t.pos+=r.data.length);if(t.nodeStart&&t.nodeEnd){var s=n.createRange();return s.setStart(t.nodeStart,t.nodeStartPos),s.setEnd(t.nodeEnd,t.nodeEndPos),t.node.clone.appendChild(s.extractContents()),s.insertNode(t.node.clone),s.detach(),!1}}return!0}(e.element,{node:o,pos:0})}),e.highlightedCode=e.element.innerHTML}}))}(self,document)}}]);