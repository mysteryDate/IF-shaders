Shader "Aaron/Ghost/Particles" 
{
	// Bound with the inspector.
 	Properties 
 	{
        _Color ("Main Color", Color) = (0, 1, 1,0.3)
        _SpeedColor ("Speed Color", Color) = (1, 0, 0, 0.3)
        _colorSwitch ("Switch", Range (0, 120)) = 60
        _Foo ("Foo", int) = 1
    }

	SubShader 
	{
		Pass 
		{
			Blend SrcAlpha one
			Ztest always

			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			// The same particle data structure used by both the compute shader and the shader.
			struct Particle
			{
				float3 position;
				float3 velocity;
			};
			
			// structure linking the data between the vertex and the fragment shader
			struct FragInput
			{
				float4 color : COLOR;
				float4 position : SV_POSITION;
			};
			
			// The buffer holding the particles shared with the compute shader.
			StructuredBuffer<Particle> particleBuffer;
			StructuredBuffer<float3> positionBuffer;
			
			float4x4 _ObjectMat;
			
			// Variables from the properties.
			float4 _Color;
			float4 _SpeedColor;
			float _colorSwitch;
			int _Foo;

			FragInput vert (uint id : SV_VertexID, uint inst : SV_InstanceID)
			{
				FragInput fragInput;
				
				fragInput.position = mul(UNITY_MATRIX_VP,  float4(particleBuffer[id].position ,1));
				fragInput.color = float4(particleBuffer[id].velocity, 1);
				
				return fragInput;
			}
			
			float4 frag (FragInput fragInput) : COLOR
			{
				return float4(1,0,1,1);
//				return fragInput.color;
			}
			
			ENDCG
		
		}
	}

	Fallback Off
}
