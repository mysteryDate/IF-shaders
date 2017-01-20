// A basic cutout shader with an extra alpha blend
Shader "Aaron/basicAlpha" {
   Properties {
      _MainTex ("Color (RGB) Alpha (A)", 2D) = "white" {}
      _Alpha ("Alpha", Range(0,1)) = 1
      _Cutoff ("Cutoff", Range(0,1)) = 1
   }
   SubShader {
      Tags { "Queue" = "Transparent" "RenderType" = "Overlay" } 
         // draw after all opaque geometry has been drawn
      Pass {
         ZWrite Off // don't write to depth buffer 
            // in order not to occlude other objects
         Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         // Variables
         uniform sampler2D _MainTex;
         float _Alpha;

         //base input structs
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
         };
         
         float _Cutoff;

         // vertex function
         vertexOutput vert(vertexInput v){
            vertexOutput o;
            
            o.tex = v.texcoord;
            o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
            return o;
         }


         // Fragment function
         float4 frag(vertexOutput i) : COLOR 
         {

            float4 tex = tex2D(_MainTex, i.tex.xy);
            
            if(tex.a < _Cutoff) {
            	discard;
            }
            return float4(tex.rgb, _Alpha);
         } 
 
         ENDCG  
      }

   }
}
