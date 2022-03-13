/**
Fully parametric plant-car chassis. It generates a triangular chassis of a certain
length & width with set wall thickness and adds a pattern of triangles in between the 
ceiling and floor, which reduces material while distributing weight.
**/

use <MCAD/triangles.scad>

// the chassis' height & width are the same
length = 190;
// denominator to compute pattern width
pattern_factor = 10;
// the depth of the chassis as measure from floor to ceiling
depth = 10;
// vertical wall thickness
wall_thick = 5;
// floor and ceiling thickness
roof_thick = 2;

// ------------- chassis base -----------------------------------------
// a solid triangle with the right measurements
module solid_double_base() {  
    module half_base(b = 190, t = 10) {
        difference() {
             triangle(b, b / 2, t);
            // the inner triangle is 80% of the outer
            factor = 0.8;
            translate([wall_thick / 2, wall_thick, 0]) 
                scale([factor, factor, 1])
                    triangle(b, b / 2, t);
        }
    }
    
    half_base(length, depth);
    mirror([1, 0, 0]) half_base(length, depth);
}

// plots a solid base and makes it hull such that wall thickness matches params
module base() {    
    difference() {
        color("red") solid_double_base();
        translate([-(length / 2) + wall_thick, -0.1, wall_thick / 2])
            cube(
                [length - wall_thick * 2, length - wall_thick * 2, depth - roof_thick * 2], 
                center = false
            );
    }
}

// ------------- triangle pattern -----------------------------------------
// the width of a single triangle in the pattern - 10 is a sensible default
t_pattern_base_width = length / pattern_factor;

// a single triangle in the pattern of variable length
module single_triangle(length = length) {
    // an element is made of an outer, larger triangle with a smaller one cut into it
    module outer_triangle() {
        union() {
            rotate([0, -90, 0]) triangle(t_pattern_base_width / 2, depth - 3, length);
            mirror([0, 1, 0]) 
                rotate([0, -90, 0]) triangle(t_pattern_base_width / 2, depth - 3, length);
        }
    }

    difference() {
        outer_triangle();
        scale([1, 0.8, 0.8]) outer_triangle();
    }
}

// a triangle pattern is made of a single vertical row for the base and n horizontal rows
// that cover the height of the chassis
module triangle_pattern(n=1) {   
    union() {
        // make n horizontal rows of long triangles
        for (i = [0:1:n-1]) {
            translate([0, 19*i, 0])
                translate([length / 2, t_pattern_base_width / 2 + wall_thick, roof_thick]) 
                    single_triangle();
        }
        
        // make a single vertical row of short triangles
        for (i = [-10:1:10]) {
            translate([
                t_pattern_base_width / 2 + i*t_pattern_base_width, 
                wall_thick * 2, 
                roof_thick
            ]) 
                rotate([0, 0, 90]) single_triangle(10);
        }
    }
}

//// the final chassis is a union of the base and the pattern
union() {
    color("blue") base();
    // this intersection generates the actual pattern
    intersection() {
        solid_double_base();
        triangle_pattern(n = 50);
    }
}