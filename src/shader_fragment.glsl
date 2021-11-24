#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define SPHERE 0
#define BUNNY  1
#define PLANE  2
#define GUN1   3
#define CUBE   4
#define CUBE_marrom   5
#define CUBE_pine   6
#define COW   7
#define TURRET   8
#define BASE   9
uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
//uniform sampler2D TextureImage4;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

vec4 n = normalize(normal);
vec4 l = normalize(vec4(1.0,10.0,0.5,0.0));
vec4 r = -l + 2 * n * dot(n,l); // PREENCHA AQUI o vetor de reflexão especular ideal

vec3 Kd; // Refletância difusa
vec3 Ks; // Refletância especular
vec3 Ka; // Refletância ambiente
float q; // Expoente especular para o modelo de iluminação de Phong

vec3 Kd0;
void main()
{
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    vec4 p = position_world;
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,0.0,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == SPHERE ) {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

/*
        */
        vec4 vP = position_model - bbox_center;
        float theta = atan(vP.x, vP.z);
        float phi = asin(vP.y);

        U = (theta+ M_PI) / (2*M_PI);
        V = (phi + M_PI_2) / M_PI;
//        U = 0.0;
//        V = 0.0;

        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.04);
        q = 1.0;

        Kd0 = texture(TextureImage0, vec2(U,V)).rgb;
        Kd = Kd0;
    }
    else if ( object_id == BUNNY )
    {
        // PREENCHA AQUI as coordenadas de textura do coelho, computadas com
        // projeção planar XY em COORDENADAS DO MODELO. Utilize como referência
        // o slides 99-104 do documento Aula_20_Mapeamento_de_Texturas.pdf,
        // e também use as variáveis min*/max* definidas abaixo para normalizar
        // as coordenadas de textura U e V dentro do intervalo [0,1]. Para
        // tanto, veja por exemplo o mapeamento da variável 'p_v' utilizando
        // 'h' no slides 158-160 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // Veja também a Questão 4 do Questionário 4 no Moodle.

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.y - miny) / (maxy - miny);

        Ks = vec3(0.01,0.01,0.01);
        Ka = vec3(0.0,0.0,0.0);
        q = 0.3;

        Kd0 = texture(TextureImage1, vec2(U,V)).rgb;
        Kd = Kd0;
    }
    else if ( object_id == GUN1 )
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.y - miny) / (maxy - miny);

        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 vP = position_model - bbox_center;
        float theta = atan(vP.x, vP.z);
        float phi = asin(vP.y);

        U = (theta+ M_PI) / (2*M_PI);
        V = (phi + M_PI_2) / M_PI;

        Kd0 = texture(TextureImage0, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Kd = Kd0;
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;

    }

    else if ( object_id == PLANE ) {

				// U = (position_model.x - floor(position_model.x));
			  // V = (position_model.y - floor(position_model.y));
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        U = U - floor(U);
        V = V - floor(V);

        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 40.0;

        Kd0 = texture(TextureImage2, vec2(U,V)).rgb;
        Kd = Kd0;
    }
    else if ( object_id == CUBE ) {

				// U = (position_model.x - floor(position_model.x));
			  // V = (position_model.y - floor(position_model.y));
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        U = U - floor(U);
        V = V - floor(V);

        Ks = vec3(0.2,0.2,0.2);
        Ka = vec3(0.2,0.2,0.2);
        q = 40.0;

        Kd0 = texture(TextureImage1, vec2(U,V)).rgb;
        Kd = Kd0;
    }

    else if ( object_id == CUBE_marrom ) {

				// U = (position_model.x - floor(position_model.x));
			  // V = (position_model.y - floor(position_model.y));
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        U = U - floor(U);
        V = V - floor(V);

        Ks = vec3(0.2,0.2,0.2);
        Ka = vec3(0.2,0.2,0.2);
        q = 40.0;

        Kd0 = texture(TextureImage2, vec2(U,V)).rgb;
        Kd = Kd0;
    }
    else if ( object_id == COW ) {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 vP = position_model - bbox_center;
        float theta = atan(vP.x, vP.z);
        float phi = asin(vP.y);

        U = (theta+ M_PI) / (2*M_PI);
        V = (phi + M_PI_2) / M_PI;

        Kd0 = texture(TextureImage0, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Kd = Kd0;
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }

    else if ( object_id == CUBE_pine ) {

        Ks = vec3(0.7,0.4,0.0);
        Ka = vec3(0.0,0.0,0.04);
        q = 1.0;

        Kd0 = texture(TextureImage1, vec2(U,V)).rgb;
        Kd = Kd0;
        Kd = vec3(0.0,0.0,0.0);

    }
    else if ( object_id == BASE ) {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 vP = position_model - bbox_center;
        float theta = atan(vP.x, vP.z);
        float phi = asin(vP.y);

        U = (theta+ M_PI) / (2*M_PI);
        V = (phi + M_PI_2) / M_PI;

        Kd0 = texture(TextureImage1, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Kd = Kd0;
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }
    else if ( object_id == TURRET ) {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 vP = position_model - bbox_center;
        float theta = atan(vP.x, vP.z);
        float phi = asin(vP.y);

        U = (theta+ M_PI) / (2*M_PI);
        V = (phi + M_PI_2) / M_PI;

        Kd0 = texture(TextureImage1, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Kd = Kd0;
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }

    else // Objeto desconhecido = preto
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
        Kd0 = Kd;
    }

    // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0

    vec3 I = vec3(1.0,1.0,1.0); // PREENCH AQUI o espectro da fonte de luz
    vec3 Ia = vec3(0.2,0.2,0.2); // PREENCHA AQUI o espectro da luz ambiente
    // Equação de Iluminação
    vec3 lambert_diffuse_term = Kd * I * max(0,dot(n,l)); // PREENCHA AQUI o termo difuso de Lambert
    //float lambert = max(0,dot(n,l));

    color = Kd0 * (lambert_diffuse_term + 0.01);

    vec3 ambient_term = Ka * Ia; // PREENCHA AQUI o termo ambiente
    vec3 phong_specular_term  = Ks * I * pow(max(0,dot(r,v)),q);// PREENCH AQUI o termo especular de Phong
    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = lambert_diffuse_term + ambient_term + phong_specular_term;
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
} 

