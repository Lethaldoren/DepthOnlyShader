Shader "Hidden/PostEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineColor("Color", Color) = (0,0,255,255)
		_MinBrightness("MinBrightness", Float) = 0
		_MaxBrightness("MaxBrightness", Float) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _CameraNormalsTexture;
			sampler2D _CameraDepthTexture;
			sampler2D _CameraDepthNormalsTexture;
			fixed4 _OutlineColor;
			float _MinBrightness; 
			float _MaxBrightness; 


			fixed4 frag (v2f i) : SV_Target
			{			
				float2 stride = (_ScreenParams.zw - 1.0f) * 0.5f;
				float2 signs = float2(1,-1);

				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));

				//get the depth difference between the neighboring pixels
				fixed4 tr = tex2D(_CameraNormalsTexture, i.uv + stride * signs.xx);
				fixed4 tl = tex2D(_CameraNormalsTexture, i.uv + stride * signs.yx);
				fixed4 br = tex2D(_CameraNormalsTexture, i.uv + stride * signs.xy);
				fixed4 bl = tex2D(_CameraNormalsTexture, i.uv + stride * signs.yy);

				fixed4 horizontal = tr + br - tl - bl;
				fixed4 vertical = tl + tr - bl - br;

				float total = 1.0f * dot(horizontal, horizontal) + dot(vertical, vertical);

				//clamp the dephth difference to the min and max brightness values
				if ( total > 0.02) {
					clamp(total, _MinBrightness, _MaxBrightness);
				}

				float brightness = saturate(1.0f + fmod(depth, 2.0f));

				return (total  * _OutlineColor) * 0.5f * brightness;		
 
			}
			ENDCG
		}
	}
}
