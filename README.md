# RYTransparentPanningCurve

Objective: 
to expand or collapse a bottom half subview with the help of a transparent curve.

Scenario 1: 
We have 2 subviews of a superview.
Top one is static but bottom one can be swiped(panned) up and down. When swaped up, it now occupies the entire space of its superview. 
When swiped down, again it returns to its original position(bottom half of its parent)

Requirements:
i. Top edge of this subview is curved.
ii. Curve is transparent i.e top subview's content is seen in the curve's portion.
iii. When bottom subview is swiped up or down, the curve too changes its shape along with its size.
iv. On touch up, either complete the animation or return to its initial position. This movement is not abrupt but animated.

![Video link](https://bitbucket.org/RYTheDev/rytransparentpanningcurve/downloads/RYTransparentPanningCurve.MP4)
