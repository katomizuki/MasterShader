Shader "Unlit/stencilblur"
{
    Properties
    {
        // テクスチャを外部のスクリプトから動的に変更したい場合
        [PerRendererDaa] _MainTex ("Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
    }
    SubShader
    {
        Tags { 
            // 
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtalas"="True" 
            }
        
        Stencil {
            // ステンシルテストの基準値
            Ref [_Stencil]
            // 比較関数
            Comp [_StencilComp]
            // 成功時の挙動
            Pass [_StencilOp]
            // バッファ読み込み時のビットマスク
            ReadMask [_StencilReadMask]
            // バッファ書き込み時のビットマスク
            WriteMask [_StencilWriteMask]
            }
        
        // UIなのでカリング不要
        Cull Off
        // UIなのでライティング不要
        Lighting Off
        // Transparentなので深度書き込み不要
        ZWrite Off
        // OverLayではAlwaysになるが、そうでなければLEqualになってくれる
        ZTest [unity_GUIZTestMode]
        // シェーダーのアルフォ値 * (1　ー 元のアルファ値)
        Blend SrcAlpha OneMinusSrcAlpha
        // 描画を反映しないカラーチャネルを設定
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 速さ優先
            #pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            // RectMask2Dの有無でクリッピング機能の有無も切り替えられる
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            // アルファ値でクリッピング機能のうむを切り分け
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color: COLOR;
                float2 uv : TEXCOORD0;
                // instancingが有効であればInstanceIdを付与する
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color: COLOR;
                float3 worldPosition : TEXCOORD1;
                float4 pos : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            sampler2D _GrabBlurTexture;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.pos.xy / i.pos.w;
                uv.y = 1.0 / uv.y;
                half4 color = (tex2D(_GrabBlurTexture, uv) + _TextureSampleAdd) * i.color;
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                // 0.001でほぼ透明ならピクセルの破棄
                clip (color.a - 0.001);
                #endif

                // マスク画像を取得
                half4 mask = tex2D(_MainTex, i.uv);
                // マスク画像のアルファ値をcolorに入れてあげる。
                color.a *= mask.a;
               return color; 
            }
            ENDCG
        }
    }
}
