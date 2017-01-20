Shader "Aaron/Avatar/8back_toStencilBuffer" {
   Properties {
      _BackTex ("Back Texture", 2D) = "BlueSpace" {}
      _BumpTex ("Bumpmap", 2D) = "bump" {}
      _RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
      _RimPower ("Rim Power", Range(0.1,8)) = 0.5
      _BumpDepth ("BumpDepth", Range(.00001,3.0)) = 2.2
	  _TextureShift ("Texture Shift", Vector) = (0.54,0.7,0,0)
	  _TextureScale ("Texture Scale", Vector) = (8.55,27.53,0,0)
	  _IFPos ("IF Position", Vector) = (0,0,0,0)
	  [MaterialToggle] _UseUV ("Use UV Map", Float) = 0
      
   }
   SubShader {
      Tags { "Queue" = "Geometry"} 
      
      // Write 1s to the stencil buffer
      Stencil
      {
		 Ref 1
		 Comp always
		 Pass replace
      }
      
      Pass {
      	 Tags { "LightMode" = "ForwardBase"}
      	
         Cull Front // first pass renders only back faces
         ZWrite On // write to the depth buffer, since this side is opaque
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
         #include "UnityCG.cginc"
 
         // Variables
         uniform sampler2D _BackTex;
         float4 _BackTex_ST;
         uniform sampler2D _BumpTex;
         float4x4 _AvatarViewMatrix;
         float4x4 _AvatarProjectionMatrix;
         float4x4 _AvatarModelMatrix;
         float _BumpDepth;
         float4 _TextureShift;
         float4 _TextureScale;
         float4 _RimColor;
         float _RimPower;
         float _UseUV;
         
         // Lighting
         float4 _LightColor0;

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
            float2 tex : TEXCOORD2;
            float3 tangentDir : TEXCOORD3;
            float3 binormalDir: TEXCOORD4;
            float4 viewPos : TEXCOORD5;
         };

         // vertex function
         vertexOutput vert(vertexInput v){
            vertexOutput o;
            
            o.normalDir = ( mul( float4(v.normal, 0.0), _World2Object).xyz );
            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
            o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
            
            o.posWorld = mul(_Object2World, v.vertex);
            o.tex = TRANSFORM_TEX(v.texcoord, _BackTex);
            o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
            float4x4 finalMatrix = mul(mul(_AvatarProjectionMatrix, _AvatarViewMatrix), _Object2World);
            o.viewPos = mul(finalMatrix, v.vertex);
            return o;
         }


         // Fragment function
         float4 frag(vertexOutput i) : COLOR 
         {
         	float atten = 1.0;
         	
         	// Normals from bumpmap
            float4 texN = tex2D(_BumpTex, i.tex.xy);
            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
			localCoords.z = _BumpDepth;
            float3x3 local2WorldTranspose = float3x3(
               i.tangentDir,
               i.binormalDir,
               i.normalDir);
            float3 normalDirection = -normalize( mul(localCoords, local2WorldTranspose));
//            float3 normalDirection = -i.normalDir; // If we just want the damn normal
            
            // Lighting
            float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
            
            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
            float rim = (1 - dot(normalize(viewDirection), normalDirection));

			float2 newPos = (i.viewPos.xy + _TextureShift.xy) / _TextureScale.xy;
			
			if(_UseUV == 1) {
				newPos = i.tex.xy;
			}

            float4 tex = tex2D(_BackTex, newPos);
            float4 finalColor = tex + _RimColor * pow(rim, -_RimPower);
            
            return float4(tex.rgb * diffuseReflection, 1);
         } 
 
         ENDCG  
      }
//      Pass {
//      	 Tags { "LightMode" = "ForwardAdd"}
//      	 Blend One One
//         Cull Front // first pass renders only back faces
//         ZWrite On // write to the depth buffer, since this side is opaque
// 
//         CGPROGRAM 
// 
//         #pragma vertex vert 
//         #pragma fragment frag
//         #include "UnityCG.cginc"
// 
//         // Variables
//         uniform sampler2D _BackTex;
//         float4 _BackTex_ST;
//         uniform sampler2D _BumpTex;
//         float4x4 _AvatarViewMatrix;
//         float4x4 _AvatarProjectionMatrix;
//         float4x4 _AvatarModelMatrix;
//         float _BumpDepth;
//         float4 _TextureShift;
//         float4 _TextureScale;
//         float4 _RimColor;
//         float _RimPower;
//         float _UseUV;
//         
//         // Lighting
//         float4 _LightColor0;
//
//         //base input structs
//         struct vertexInput {
//            float4 vertex : POSITION;
//            float3 normal : NORMAL;
//            float4 texcoord : TEXCOORD0;
//            float4 tangent : TANGENT;
//         };
//         struct vertexOutput {
//            float4 pos : SV_POSITION;
//            float4 posWorld : TEXCOORD0;
//            float3 normalDir : TEXCOORD1;
//            float2 tex : TEXCOORD2;
//            float3 tangentDir : TEXCOORD3;
//            float3 binormalDir: TEXCOORD4;
//            float4 viewPos : TEXCOORD5;
//         };
//
//         // vertex function
//         vertexOutput vert(vertexInput v){
//            vertexOutput o;
//            
//            o.normalDir = ( mul( float4(v.normal, 0.0), _World2Object).xyz );
//            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
//            o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
//            
//            o.posWorld = mul(_Object2World, v.vertex);
//            o.tex = TRANSFORM_TEX(v.texcoord, _BackTex);
//            o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
//            float4x4 finalMatrix = mul(mul(_AvatarProjectionMatrix, _AvatarViewMatrix), _Object2World);
//            o.viewPos = mul(finalMatrix, v.vertex);
//            return o;
//         }
//
//
//         // Fragment function
//         float4 frag(vertexOutput i) : COLOR 
//         {
//         	float atten = 1.0;
//         	
//         	// Normals from bumpmap
//            float4 texN = tex2D(_BumpTex, i.tex.xy);
//            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
//			localCoords.z = _BumpDepth;
//            float3x3 local2WorldTranspose = float3x3(
//               i.tangentDir,
//               i.binormalDir,
//               i.normalDir);
//            float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));
////            float3 normalDirection = -i.normalDir; // If we just want the damn normal
//            
//            // Lighting
//			
//			
//			float3 vertexToLightSource = float3(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
//			float distance = length(vertexToLightSource);
//			float3 lightDirection = normalize( lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
//			atten = lerp(1.0, 1.0/distance, _WorldSpaceLightPos0.w);
//			
//			float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
//            
//            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
//            float rim = (1 - dot(normalize(viewDirection), normalDirection));
//
//			float2 newPos = (i.viewPos.xy + _TextureShift.xy) / _TextureScale.xy;
//			
//			if(_UseUV == 1) {
//				newPos = i.tex.xy;
//			}
//
//            float4 tex = tex2D(_BackTex, newPos);
//            float4 finalColor = tex + _RimColor * pow(rim, -_RimPower);
//            
//            return float4(diffuseReflection, 1);
//         } 
// 
//         ENDCG  
//      }
      
   }
   Fallback "Diffuse"
}
