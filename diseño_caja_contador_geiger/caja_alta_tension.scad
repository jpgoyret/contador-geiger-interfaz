// Carcasa para la placa de alta tensión

// Dimensiones que dan un resultado con sentido
//FootDia = 0.2;
//FootHole = 0.02;
//FootHeight = 0.2;
//Thick = 0.1;
//
//x = 3;
//y = 2;
//z = 1;
//dx = 0.4;
//dy = 0.4;
//dz = 0.4;
//rx = 0.1;
//ry = 1.8;
//rz = 0.1;

//DIMENSIONES DE LA PLACA
//9.4cm x 10.2 cm

//Dimensiones reales
//
FootDia = 8;    //Diametro del pie para la placa
FootHole = 0.1; //Agujero del tornillo
FootHeight = 5; //Altura del pie para la placa
Thick = 0.1;
Filet = 0.1;        //Constante que define el ancho de la base de los soportes para la placa

x = 114+2;
y = 115.3+2;
z = 70+2;
dx = 4+2;
dy = 4+2;
dz = 4+2;
rx = 1;
ry = 18;
rz = 1;

ex1 = 10;   //Espacio entre pared y placa del eje x en una dirección
ex2 = 3;    //Espacio entre pared y placa del eje x en la otra
ey1 = 3;    //Espacio entre pared y placa del eje y en una dirección
ey2 = 3.3;  //Espacio entre pared y placa del eje y en la otra

sx = 7;     //Espacio entre borde placa y pos. del agujero(+diametro)
sy = 5;    //Espacio entre el borde de la placa y la posicion del agujero (sumado el diametro)



// Posiciones de los soportes para la placa---------------
//pos_soportex1 = -x/2 + dx + ex2 + sx - FootDia/2;
pos_soportex1 = -x/2 + dx - (FootDia+Filet)/2 + sx + ex2;
//pos_soportex2 = x/2 - dx - ex2 - sx + FootDia/2;
pos_soportex2 = x/2 - dx + (FootDia+Filet)/2 - sx - ex1;
//pos_soportey1 = -y/2 + dy + ey1 + sy - FootDia/2;
pos_soportey1 = -y/2 + dy+ ey1 + sy - (FootDia+Filet)/2;
//pos_soportey2 = y/2 - dy - ey2 - sy + FootDia/2;
pos_soportey2 = y/2 - dy - ey2 - sy + (FootDia+Filet)/2;
pos_soportez = -(z-dz)/2;

//Agujero tubo---------------------------------------------------
//FUE CHEQUEADO
tubo_z = 27;
tubo_y = 10;
pos_tubo_x = x/2 - dx/4;
//pos_tubo_y = -y/2 + 45 - tubo_y/2;
pos_tubo_y = -y/2 -tubo_y/2 + 45;
//pos_tubo_z = -z/2 + 5 + 25 + tubo_z/2 + dz;
pos_tubo_z = -z/2 + tubo_z/2 + 30 + FootHeight;
espesor_tubo = dx/2;

//Agujero Arduino-----------------------------------------------

arduino_x = 22;
arduino_z = 27;
pos_arduino_x = -x/2 + dx/4 + 65;
pos_arduino_y = -y/2 - dy/4;
pos_arduino_z = -z/2 + 30 + arduino_z/2;
espesor_arduino = dy/2;

//Agujero jack energía------------------------------------------

jack_x = 13;
jack_z = 14;
pos_jack_x = -x/2 + dx/4 + 33;
pos_jack_y = -y/2 - dy/4;
pos_jack_z = -z/2 + 30 + jack_z/2;
espesor_jack = dy/2;

//Ayuda para tornillo-------------------------------------------

tx = 10;
ty = 10;
tz = 35;
pos_tx = x/2-dx/2 - tx/2;
pos_ty = y/2-dy/2 - ty/2;
pos_tz = z/2 - tz/2;
d_tornillo = 2;

//Ayuda para tornillo tapa------------------------------------

ttx = 70;
tty = 12;
ttz = 12;
pos_ttx = 0;
pos_tty = -y/2 + tty/2;
pos_ttz = -z/2 + ttz/2 + dz;

//Barras anti-flexibilidad--------------------------------------
off_z = 20;
off_x = 30;
bx = sqrt(pow(z-dz - off_z,2) + pow(y-dy,2)) - off_x;
by = dx/2;
bz = dx ;
pos_bx = x/2 - dx;
pos_by = y/2 - by/2 - dy/2;
pos_bz = z/2 - bz/4;
theta = atan((z-dz- off_z) / (y-dy));
alfa = atan((z-dz)/35);



module foot(FootDia,FootHole,FootHeight,Thick,Filet){
// Pie posa PCB
    // FootDia: diámetro de la parte donde se posa
    // FootHole: diámetro del agujero
    // FootHeigth: Altura del pie
    // Thick: cuanto se achica el pie para posar el PCB
    //Filet=2;  
    translate([0,0,0])
    difference(){
    
    difference(){
            //translate ([0,0,-Thick]){
                cylinder(d=FootDia+Filet,FootHeight-Thick, $fn=100);
                        //}
                    rotate_extrude($fn=100){
                            translate([(FootDia+Filet*2)/2,Filet,0]){
                                    minkowski(){
                                            square(10);
                                            circle(Filet, $fn=100);
                                        }
                                 }
                           }
                   }
            cylinder(d=FootHole,FootHeight+1, $fn=100);
               }          
}

module parte_inferior (x,y,z,dx,dy,dz,rx,ry,rz,tapa){
// Parte inferior de la placa de alta tensión
    
    // x: largo eje x
    // y: largo eje y
    // z: largo eje z
    // dx: grosor de la pared en el eje x
    // dy: grosor de la pared en el eje y
    // dz: grosor de la pared en el eje z
    // rx: largo del riel para encajar la tapa en el eje x
    // ry: largo del riel para encajar la tapa en el eje y
    // rz: largo del riel para encajar la tapa en el eje z
    //tapa: si vale 1 se genera la tapa, si vale 0, no
    
    difference(){
    
        cube([x,y,z],center=true);
        translate ([0,-dy/2,dz/2]) cube([x-dx,y,z],center=true);
//        translate ([x/2-dx/4,-(y-ry)/2,z/2-rz/2]) cube([rx,ry,rz],center=true);
//        translate ([-(x/2-dx/4),-(y-ry)/2,z/2-rz/2]) cube([rx,ry,rz],center=true);
//        translate ([-(x/2-dx/4),-(y-ry)/2,z/2-rz]) cube([rx*1.5,ry,rz],center=true);
//        translate ([x/2-dx/4,-(y-ry)/2,z/2-rz]) cube([rx*1.5,ry,rz],center=true);        
    }
}

module soporte_placa(x1,x2,y1,y2,z){
// Los cuatro pies donde se posa la placa

    translate ([x1,y1,z]) foot(FootDia,FootHole,FootHeight,Thick,Filet);
    translate ([x1,y2,z]) foot(FootDia,FootHole,FootHeight,Thick,Filet);
    translate ([x2,y1,z]) foot(FootDia,FootHole,FootHeight,Thick,Filet);
    translate ([x2,y2,z]) foot(FootDia,FootHole,FootHeight,Thick,Filet);    
    
}

//module tapa(x,y,z,dx,dy,dz,rx,ry,rz)
module tapa(x,y,z,dx,dy,dz)
{
    
    union(){
        translate ([0,-y/2-dy/4,0]) cube([x,dy/2,z],center=true);
        
        translate ([0,-dy/4,z/2+dz/4]) cube([x,y+dy/2,dz/2],center=true);
        
//        translate ([x/2-dx/4,-(y-ry)/2,z/2-rz]) cube([rx*1.5,ry,rz],center=true);
//        translate ([x/2-dx/4,-(y-ry)/2,z/2-rz/2]) cube([rx,ry,rz],center=true);
//        
//        translate ([-(x/2-dx/4),-(y-ry)/2,z/2-rz/2]) cube([rx,ry,rz],center=true);
//        translate ([-(x/2-dx/4),-(y-ry)/2,z/2-rz]) cube([rx*1.5,ry,rz],center=true);
        
        
        
    }
}

module agujero(dim_x,dim_y,dim_z,pos_x,pos_y,pos_z){
    
    translate ([pos_x,pos_y,pos_z]) cube([dim_x,dim_y,dim_z],center = true);    
}

module ayuda_para_tornillo(tx,ty,tz,pos_tx,pos_ty,pos_tz)
{
    difference(){
        translate ([pos_tx,pos_ty,pos_tz]) cube([tx,ty,tz],center = true);
        translate([pos_tx-(abs(pos_tx)/pos_tx)*tx/2,pos_ty-(abs(pos_tx)/pos_tx)*ty/2,pos_tz-tz/2]) rotate (a = [(abs(pos_tx)/pos_tx)*(-1)*90,-90,0]) linear_extrude(tx) polygon([[0,0],[tz,0],[0,ty]], paths=[[0,1,2]]);
        translate([pos_tx+(abs(pos_tx)/pos_tx)*tx/4,pos_ty+ty/8,pos_tz + tz/2]) cylinder(h = tz/2 ,d = d_tornillo, $fn = 100,center = true);
        
        
    }
}



module barras_anti_flex(bx,by,bz,theta)
{
    rotate (a = [0,theta,0]) cube ([bx,by,bz], center = true);
}

////////////////////// GENERACION DE LA PIEZA ////////////////////

//======================CAJA==========================\\

//rotate (a = [0,90,0]) difference(){

union(){
difference(){
    parte_inferior (x,y,z,dx,dy,dz,rx,ry,rz);
    //Agujero del tubo
    agujero(espesor_tubo*2,tubo_y,tubo_z,pos_tubo_x,pos_tubo_y,pos_tubo_z);
    
}
//Soporte placa
soporte_placa (pos_soportex1,pos_soportex2,pos_soportey1,pos_soportey2,pos_soportez);

//Ayuda para tornillo
ayuda_para_tornillo(tx,ty,tz,pos_tx,pos_ty,pos_tz);
ayuda_para_tornillo(tx,ty,tz,-pos_tx,pos_ty,pos_tz);
//ayuda_para_tornillo(ty,tx,tz,-pos_tx+tx,pos_ty+tx,pos_tz);
//ayuda_para_tornillo(ty,tx,tz,+pos_tx-tx,pos_ty+tx,pos_tz);
////Ayuda para flexibilidad de caja
//translate ([0,pos_by,5]) barras_anti_flex(bx,by,bz,theta);
//
//translate ([0,pos_by,5]) barras_anti_flex(bx,by,bz,-theta);
//
//translate([-pos_bx,0,5]) rotate (a =[0,0,90]) barras_anti_flex(bx,by,bz,theta);
//
//translate([-pos_bx,0,5]) rotate (a =[0,0,90]) barras_anti_flex(bx,by,bz,-theta);
//
//translate([pos_bx,0,5]) rotate (a =[0,0,90]) barras_anti_flex(bx,by,bz,-theta);
//translate([pos_bx,-y/4,5]) rotate (a =[0,0,-90]) barras_anti_flex(bx-35,by,bz,-alfa);
//translate([pos_bx,y/6,5]) rotate (a =[0,0,-90]) barras_anti_flex(bx-35,by,bz,-alfa);


}
    //translate([-ex1,0,0]) cube([x,y,z],center=true);
//}




//======================TAPA==========================\\

//translate ([0,-y/3,0]) union(){
//    difference(){
////        translate ([0,-y/3,0]) 
//        tapa(x,y,z,dx,dy,dz);
//        //Agujero del Arduino
//        agujero(arduino_x,espesor_arduino*2,arduino_z,pos_arduino_x,pos_arduino_y,pos_arduino_z);
//        //Agujero del jack de energía
//        agujero(jack_x,espesor_jack*2,jack_z,pos_jack_x,pos_jack_y,pos_jack_z);
//        
//        
//    }
//    ayuda_para_tornillo(ttx,tty,ttz,pos_ttx,pos_tty,pos_ttz);
//    translate([0,0,pos_bz]) rotate (a =[90,0,0]) barras_anti_flex(bx,by,bz,-theta);
//    translate([0,0,pos_bz]) rotate (a =[-90,0,0]) barras_anti_flex(bx,by,bz,-theta);
//    
//}


