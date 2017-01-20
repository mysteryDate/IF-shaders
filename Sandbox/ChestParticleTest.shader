Shader "Aaron/Sandbox/ChestParticleTest" {
	Properties {
    	_Color ("Color", Color) = (1,0,0,0) 
    	_Alpha ("Alpha", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
//		Pass {
//			Cull Front
//			Blend SrcAlpha OneMinusSrcAlpha
//			Zwrite On
//			CGPROGRAM
//			#pragma vertex vert
//			#pragma fragment frag
//			
//
//			float4 _Color;
//			float _Alpha;
//			
//			struct avatarMeshPoint
//			{
//				float3 vertex;
//				float distance;
//			};
//			
//			struct vertexInput {
//				float4 vertex : POSITION;
//			};
//			struct vertexOutput {
//				float4 pos : SV_POSITION;
//				float4 color : COLOR;
//			};
//			
//			StructuredBuffer<avatarMeshPoint> meshPoints;
//			
//			vertexOutput vert(vertexInput v, uint id : SV_VertexID, uint inst : SV_InstanceID) {
//				vertexOutput o;
//
//				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
//				o.color = _Color;
//				return o;
//			}
//
//			float4 frag(vertexOutput i) : COLOR
//			{
//				return float4(i.color.rgb, _Alpha);
//			}
// 
//			ENDCG
//		}
		Pass {
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			Zwrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			

			float4 _Color;
			float _Alpha;
			
			struct avatarMeshPoint
			{
				float3 vertex;
				float distance;
			};
			
			struct vertexInput {
				float4 vertex : POSITION;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 color : COLOR;
			};
			
			StructuredBuffer<avatarMeshPoint> meshPoints;
			
			vertexOutput vert(vertexInput v, uint id : SV_VertexID, uint inst : SV_InstanceID) {
				vertexOutput o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = _Color;
				return o;
			}

			float4 frag(vertexOutput i) : COLOR
			{
				return float4(i.color.rgb, _Alpha);
			}
 
			ENDCG
		}
		
	} 
	FallBack "Diffuse"

}
