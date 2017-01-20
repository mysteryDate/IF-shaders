Shader "Aaron/Avatar/7front_ContainedParticles" {
   Properties {
      _MainTex ("Color (RGB) Alpha (A)", 2D) = "black" {}
      _BumpTex ("Bumpmap", 2D) = "bump" {}
      _AlphaMask ("Alpha Mask", 2D) = "white" {}
      _FrontColor ("Front Color", Color) = (0, 0, 0.24, 0.0)
      _RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
      _RimPower ("Rim Power", Range(0.1,8)) = 0.5
      _BumpDepth ("BumpDepth", Range(0.2,3.0)) = 2.2
	  _BaseAlpha ("Minimum Alpha", Range(0,1)) = 0.2
	  _MaxAlpha ("Maximum Alpha", Range(0,1)) = 0.9	
      [MaterialToggle] _IsInner("Inner View", Float) = 0
      
   }
   SubShader {
      Tags { "Queue" = "Transparent+2" "RenderType" = "Transparent" } 
         // draw after particles
 
      Pass {
         Cull Back // second pass renders only front faces 
             // (the "outside")
         ZWrite On // Write to depth buffer to occlude particles in opaque bits
         Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         // Variables
         uniform sampler2D _MainTex;
         uniform sampler2D _BumpTex;
         uniform sampler2D _AlphaMask;
         float4 _FrontColor;
         float4 _RimColor;
         float _RimPower;
         float _BumpDepth;
         float _BaseAlpha;
         float _MaxAlpha;	
         float _IsInner;

         //base input structs
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
            float4 tangent : TANGENT;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
            float3 normalDir : TEXCOORD1;
            float4 tex : TEXCOORD2;
            float3 tangentDir : TEXCOORD3;
            float3 binormalDir: TEXCOORD4;
            float3 closestPoint: TEXCOORD5;
         };

         // vertex function
         vertexOutput vert(vertexInput v){
            vertexOutput o;
            
            o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
            o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
            
            o.posWorld = mul(_Object2World, v.vertex);
            o.tex = v.texcoord;
            o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
            return o;
         }


         // Fragment function
         float4 frag(vertexOutput i) : COLOR 
         {

            float4 texN = tex2D(_BumpTex, i.tex.xy);
            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
            localCoords.z = _BumpDepth;

            float3x3 local2WorldTranspose = float3x3(
               i.tangentDir,
               i.binormalDir,
               i.normalDir);

            float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));

            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

            float rim = (1 - dot(normalize(viewDirection), normalDirection));
            
            float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
            
            float4 finalColor = _FrontColor + _RimColor * pow(rim, _RimPower);
            
            float4 maskTex = tex2D(_AlphaMask, i.tex.xy);
            
            float al = clamp(maskTex.r, _BaseAlpha, _MaxAlpha);

            return float4(finalColor.rgb, al);
         } 
         ENDCG  
      }
   }
   Fallback "Diffuse"
}
