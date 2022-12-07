Shader "Unlit/uguishader"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                // 入力構造体にGPUインスタンスのインスタンスごとのidが取れるようになる。
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                // レンダーターゲットのインデックスを格納してくれる。この具体的なインデックスがunity_streoEyeIndex
                UNITY_VERTEX_OUTPUT_STEREO
                // unity_StereoEyeIndex　左右の目で切り替えるインデックスを割り当てる用のもの。
            };

            sampler2D _MainTex;
            sampler2D _TouchMap;
            fixed4 _Color;
            fixed4 _TExtureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float4 _Touch;

            v2f vert (appdata v)
            {
                v2f o;
                //UNITY_VERTEX_INPUT_INSTANCE_IDと連動してこれをすることでunity_InstanceIDを取れるようになる。 
                UNITY_SETUP_INSTANCE_ID(v);
                // 出力構造体にレンダーターゲットのインデックスを出力するマクロ
                //UNITY_VERTEX_OUTPUT_STEREOこれを行ったので実際にv2fに出力したいので必要。(具体的にはstereoEyeIndexが格納される）
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float adj = 0.1;
                float moveX = 0.0;
                float moveY = 0.0;
                float2 gap = i.worldPosition - _Touch;
                half4 touchC = tex2D(_TouchMap, i.texcoord);
                moveX += adj * ((touchC.r - 0.5));
                moveY += adj * ((touchC.g - 0.5));
                float2 move = float2(-moveX, -moveY);
                half4 color = (tex2D(_MainTex, i.texcoord + move + _TExtureSampleAdd)) * i.color;
                color.a += UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                clip(color.a - 0.001);
                return color;
            }
            ENDCG
        }
    }
}
