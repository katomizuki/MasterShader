// Upgrade NOTE: upgraded instancing buffer 'PerDrawSprite' to new syntax.

Shader "Sprites/Sin"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0

        _SinWave("SinWave", Range(0, 1)) = 0.2
        _SinWidth("SinWidth", Range(0, 1)) = 0.5
        _SinSpeed("SinSpeed", Range(0, 1)) = 0.2
        _SinColorDistant("SinColorDistant", Range(0, 1)) = 0.2
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex SpriteVert
            #pragma fragment SpriteFrag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

			#include "UnityCG.cginc"

			#ifdef UNITY_INSTANCING_ENABLED

				UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
					// SpriteRenderer.Color while Non-Batched/Instanced.
					fixed4 unity_SpriteRendererColorArray[UNITY_INSTANCED_ARRAY_SIZE];
					// this could be smaller but that's how bit each entry is regardless of type
					float4 unity_SpriteFlipArray[UNITY_INSTANCED_ARRAY_SIZE];
				UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

				#define _RendererColor unity_SpriteRendererColorArray[unity_InstanceID]
				#define _Flip unity_SpriteFlipArray[unity_InstanceID]

			#endif // instancing

			CBUFFER_START(UnityPerDrawSprite)
			#ifndef UNITY_INSTANCING_ENABLED
				fixed4 _RendererColor;
				float4 _Flip;
			#endif
				float _EnableExternalAlpha;
			CBUFFER_END

			// Material Color.
			fixed4 _Color;

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f SpriteVert(appdata_t IN)
			{
				v2f OUT;

				UNITY_SETUP_INSTANCE_ID (IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

			#ifdef UNITY_INSTANCING_ENABLED
				IN.vertex.xy *= _Flip.xy;
			#endif

				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color * _RendererColor;

				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float _SinWave;
			float _SinWidth;
			float _SinSpeed;
			float _SinColorDistant;

			float _wave;
			float _speed;
			float _width;
			float _clrDis;

			float2 posColor(float2 inUV, float n)
			{
				return inUV + float2(sin(inUV.y *_wave + _speed + _clrDis * n) * _width, 0);
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

			#if ETC1_EXTERNAL_ALPHA
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
			#endif

				return color;
			}

			fixed4 SpriteFrag(v2f IN) : SV_Target
			{

				fixed4 color = fixed4(0, 0, 0, 0);

				float2 inUV = IN.texcoord;

				_wave = _SinWave * 100;
				_speed = _Time.y * _SinSpeed * 20.0;
				_width = _SinWidth * 0.2;
				_clrDis = _SinColorDistant * _SinWidth * 5;

				if(_SinColorDistant==0){//カラーチャンネルを分けない

					float mysin = sin(inUV.y *_wave + _speed) * _width;
					color = tex2D(_MainTex, inUV + float2(mysin, 0));

				}else{//カラーチャンネルを個別に設定

					color.r = tex2D(_MainTex, posColor(inUV, 2)).r;
					color.g = tex2D(_MainTex, posColor(inUV, 1)).g;
					color.b = tex2D(_MainTex, posColor(inUV, 0)).b;
					color.a = (
						tex2D(_MainTex, posColor(inUV, 2)).a+
						tex2D(_MainTex, posColor(inUV, 1)).a+
						tex2D(_MainTex, posColor(inUV, 0)).a
					)/3;

				}

				color *= IN.color;
				color.rgb *= color.a;

				return color;
			}

        ENDCG
        }
    }
}