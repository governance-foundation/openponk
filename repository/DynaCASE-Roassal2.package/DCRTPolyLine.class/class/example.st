examples
example
|v es e visible|
v := RTView new.
es := (RTEllipse new color: Color black; size: 20; elementsOn: #(1 2)).
e := DCRTPolyLine new color: Color red; edgeFrom: es first to: es second.
e shape addPoint: 30 @ 80.
v addAll: es; add: e.
es @ RTDraggable.
RTHorizontalLineLayout new horizontalGap: 50; on: es.
visible := false.
e @ DCRTLineHandles.

v open