mm=1;
in=25.4*mm;

phi = (1 + sqrt(5))/2;  // golden ratio, it comes up


face_size=11*mm;
vertex_size=15*mm;

edge_midpoint_unnormalized = ([phi,1,0] + [0,phi,1])/2;
edge_midpoint = edge_midpoint_unnormalized / norm(edge_midpoint_unnormalized);
edge_midpoint_x_rot = acos(edge_midpoint[2]);
edge_midpoint_z_rot = atan2(edge_midpoint[0], edge_midpoint[1]);

edge_midpoint_size = 8*mm;

rad_to_eyes = 55*mm;
sphere_rad = 58*mm;
drill_height = 2*(sphere_rad-rad_to_eyes);
print_offset = -41*mm;

// the circle that's cut out of the icosihedron faces
module face_circle() {
    rotate([0,acos(1/sqrt(3)),45]) 
    translate([0,0,rad_to_eyes])
    cylinder(r=face_size,h=drill_height); //the face
}

// the circles that are cut out of the vertex and edges of the icosihedron
module vertex_and_edge_circles() {
    color("pink")
    rotate([0,90,atan2(1,phi)])
    translate([0,0,rad_to_eyes])
    cylinder(r=vertex_size,h=drill_height); //vertex
    
    color("cyan")
    mirror([0,1,0])
    rotate([edge_midpoint_x_rot,0,edge_midpoint_z_rot])
    translate([0,0,rad_to_eyes])
    cylinder(r=edge_midpoint_size,h=drill_height);    
}

// an object representing what goes on one face
module face_unit() 
union() {
    face_circle();
        
    vertex_and_edge_circles();
}

// an object representing the xyz axes i can move around
module axes() {
    color("red")
    rotate([0,90,0])
    cylinder(r=2*mm,h=50*mm);
    color("green")
    rotate([-90,0,0])
    cylinder(r=2*mm,h=50*mm);
    color("blue")
    cylinder(r=2*mm,h=50*mm);
}

// the icosihedron i'm trying to model has a vertex here
module icosi_vertex() {
    translate(10*mm*[phi,1,0])
    color("pink")
    sphere(r=100*mm);
}

module rotation_tests() {
// these two transformations take the line thru [1,1,1] to the z axis and does some
// other thing to the other two axes, don't care what it is
*
rotate([0,-acos(1/sqrt(3)),0])
rotate([0,0,-45]) 

// and this is the inverse of the above, it takes the z axis to the line thru [1,1,1]
rotate([0,acos(1/sqrt(3)),45]) 
axes();

// let's call the following transformation "rotation A"
// it rotates by 120 degrees around the line through [1,1,1]
*
rotate([0,acos(1/sqrt(3)),45]) 
rotate([0,0,120])
rotate([0,-acos(1/sqrt(3)),0])
rotate([0,0,-45]) 
axes();

// let's call the following transformation "rotation B"
// it is rotation by 72 degrees around the line through [phi,1,0]
*
rotate([0,0,atan2(1,phi)])
rotate([72,0,0])
rotate([0,0,-atan2(1,phi)])
icosi_vertex();
}

*difference(){
    sphere(sphere_rad);
    
    // these generate the whole symmetry group of the icosihedron, with much redundancy
    // just for visualization. don't push f6 when this is turned on, omg
    for(more_rotation_A_count=[0:2])
    rotate([0,acos(1/sqrt(3)),45]) 
    rotate([0,0,120*more_rotation_A_count])
    rotate([0,-acos(1/sqrt(3)),0])
    rotate([0,0,-45]) 
    
    for(rotation_B_count=[0:4])
    rotate([0,0,atan2(1,phi)]) // this is rotation B
    rotate([rotation_B_count*72,0,0])
    rotate([0,0,-atan2(1,phi)])
    
    for(rotation_A_count=[0:2])
    rotate([0,acos(1/sqrt(3)),45]) 
    rotate([0,0,120*rotation_A_count])
    rotate([0,-acos(1/sqrt(3)),0])
    rotate([0,0,-45]) 
    
    for(big_rotation=[0,1])
    rotate([big_rotation*180,big_rotation*180,0])
    face_unit();
}

// here's all holes around one face
module all_holes_around_one_face() {
    face_circle();
    for(rot_A_count = [0:2])
    rotate([0,acos(1/sqrt(3)),45]) 
    rotate([0,0,120*rot_A_count])
    rotate([0,-acos(1/sqrt(3)),0])
    rotate([0,0,-45])
    vertex_and_edge_circles();
}


// now we lop it off - making one twentieth of the ornament.
// find the normal vector to the plane through [phi,1,0] and [0,phi,1]
// point a big cylinder in that direction
// then apply rotation A 0,1,2 times to get three cylinders; and intersect those
// finally intersect that with a sphere

normal_vec = cross([phi,1,0], [0,phi,1]);
unit_normal_vec = normal_vec/norm(normal_vec);
*for(dist=[2:20:200])
translate(dist*unit_normal_vec)
sphere(r=5*mm);

lop_x_rot = acos(unit_normal_vec[2]);
lop_z_rot = atan2(unit_normal_vec[0], unit_normal_vec[1]);
module one_twentieth_of_ornament() {
    intersection() {
        intersection_for(lop_rot=[0,1,2]) {
            rotate([0,acos(1/sqrt(3)),45]) 
            rotate([0,0,120*lop_rot])
            rotate([0,-acos(1/sqrt(3)),0])
            rotate([0,0,-45]) 
            rotate([-lop_x_rot, 0, -lop_z_rot])
            cylinder(r=4*sphere_rad, h=4*sphere_rad,$fn=3); // keep $fn down for ease of rendering
        }
        difference() {
            sphere(r=sphere_rad,$fn=120);
            all_holes_around_one_face();
        }
    }
}


// finally put it straight up and down, lop off the pyramid bit and set it up for 3d printing
intersection() {
    cylinder(r=sphere_rad, h=sphere_rad);
    translate([0,0,print_offset])
    rotate([0,-acos(1/sqrt(3)),0])
    rotate([0,0,-45]) 
    one_twentieth_of_ornament();
}

