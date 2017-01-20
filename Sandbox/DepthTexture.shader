//Shows the grayscale of the depth from the camera.
 
Shader "Aaron/Sandbox/DepthShader"
{
	Properties {
		_Multiplier ("Mult", Float) = 1
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
 
        Pass
        {
        	Cull Off
 
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            uniform sampler2D _CameraDepthTexture; //the depth texture
            float _Multiplier;
 
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD1; //Screen position of pos
                float4 uv : TEXCOORD0;
            };
 
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.projPos = ComputeScreenPos(o.pos);
                o.uv = v.texcoord;
 
                return o;
            }
 
            half4 frag(v2f i) : COLOR
            {
                //Grab the depth value from the depth texture
                //Linear01Depth restricts this value to [0, 1]
//                float depth = Linear01Depth (UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));
                float depth = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)).r) * _Multiplier;
 
                half4 c;
                c.r = saturate(abs(6 * depth - 3) - 1);
                c.g = saturate(-abs(6 * depth - 2) + 2);
                c.b = saturate(-abs(6 * depth - 4) + 2);
                c.a = 1;
//				c.r = depth;
 
                return c;
            }
 
            ENDCG
        }
    }
    FallBack "VertexLit"
}