// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A JS Interop sample accessing the Google Charts API.  The sample is based on
// the Bubble Chart example here:
// https://developers.google.com/chart/interactive/docs/gallery/bubblechart

import 'dart:html';
import 'package:js/js.dart' as js;

void drawVisualization() {
  var gviz = js.context.google.visualization;

  // Create and populate the data table.
  var listData = [                  
          ['Task', 'Hours per Day'],
          ['Work',     11],
          ['Eat',      2],
          ['Commute',  2],
          ['Watch TV', 2],
          ['Sleep',    7]        
  ];

  var arrayData = js.array(listData);

  var tableData = gviz.arrayToDataTable(arrayData);

  var options = js.map({
    "title": 'My Daily Activities'
  });

  // Create and draw the visualization.
  var chart = new js.Proxy(gviz.PieChart, querySelector('#visualization'));
  chart.draw(tableData, options);
}

main() {
  js.context.google.load('visualization', '1', js.map(
    {
      'packages': ['corechart'],
      'callback': drawVisualization,
    }));
}
