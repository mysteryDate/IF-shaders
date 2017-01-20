Shader "Aaron/Avatar/2_TwoSided" {
   Properties {
      _MainTex ("Color (RGB) Alpha (A)", 2D) = "white" {}
      _BumpTex ("Bumpmap", 2D) = "bump" {}
      _RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
      _RimPower ("Rim Power", Range(0.1,8)) = 0.5
      _Alpha ("Alpha", Range(-10,8)) = -4
      _BumpDepth ("BumpDepth", Range(0.1,3.0)) = 1
   }
   SubShader {
      Tags { "Queue" = "Transparent" "RenderType" = "Transparent" } 
         // draw after all opaque geometry has been drawn
      Pass {
         Cull Front // first pass renders only back faces 
             // (the "inside")
         ZWrite Off // don't write to depth buffer 
            // in order not to occlude other objects
         Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         // Variables
         uniform sampler2D _MainTex;
         uniform sampler2D _BumpTex;
         float4 _RimColor;
         float _Alpha;
         float _RimPower;
         float _BumpDepth;

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
            // Unity stores textures in [0,1] on alpha and green
            // This converts to [-1,1] on red and green (0 for blue)
            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
            // TODO: attach a slider to this and see what happens
//            localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords);
			localCoords.z = _BumpDepth;

            float3x3 local2WorldTranspose = float3x3(
               i.tangentDir,
               i.binormalDir,
               i.normalDir);

            float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));
            //float3 normalDirection = i.normalDir;
            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

            float rim = (1 - dot(normalize(viewDirection), normalDirection));
            float al = pow(rim, _Alpha);

            float4 tex = tex2D(_MainTex, i.tex.xy);
            float4 finalColor = tex + _RimColor * pow(rim, -_RimPower);
            //return float4(_RimColor.xyz * pow(rim, _RimPower), al);
            return float4(finalColor.rgb, al);
         } 
 
         ENDCG  
      }
 
      Pass {
         Cull Back // second pass renders only front faces 
             // (the "outside")
         ZWrite Off // don't write to depth buffer 
            // in order not to occlude other objects
         Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         // Variables
         uniform sampler2D _MainTex;
         uniform sampler2D _BumpTex;
         float4 _RimColor;
         float _Alpha;
         float _RimPower;
         float _BumpDepth;

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
            // Unity stores textures in [0,1] on alpha and green
            // This converts to [-1,1] on red and green (0 for blue)
            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
            // TODO: attach a slider to this and see what happens
            //localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords);
            localCoords.z = _BumpDepth;

            float3x3 local2WorldTranspose = float3x3(
               i.tangentDir,
               i.binormalDir,
               i.normalDir);

            float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));
            //float3 normalDirection = i.normalDir;
            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

            float rim = (1 - dot(normalize(viewDirection), normalDirection));
            float al = pow(rim, -_Alpha);


            float4 tex = tex2D(_MainTex, i.tex.xy);
            float4 finalColor = tex + _RimColor * pow(rim, _RimPower);
            //return float4(_RimColor.xyz * pow(rim, _RimPower), al);
            return float4(finalColor.rgb, al);
//			return float4(normalDirection, 1.0);

         } 
         ENDCG  
      }
   }
   Fallback "Diffuse"
}
