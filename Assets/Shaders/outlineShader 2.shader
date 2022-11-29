Shader "Unlit/outlineImage" {
    Properties {
        _MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
        _BlurColor ("Blur Color", Color) = (1, 1, 1, 1)
        _BlurSize ("Blur Size", float) = 1
    }
// CGINCLUDE~ENDCGまでのパスを共通処理として扱うことができる
    CGINCLUDE
    struct appdata {
        float4 vertex   : POSITION;
        float2 texcoord : TEXCOORD0;
    };

    struct v2f {
        float4 vertex   : SV_POSITION;
        half2 texcoord  : TEXCOORD0;
        float4 worldPosition : TEXCOORD1;
    };

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    fixed4 _BlurColor;
    float _BlurSize;

    v2f vert (appdata v) {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
        o.texcoord = v.texcoord;
        return o;
    }

    fixed4 frag(v2f v) : SV_Target {
        half4 color = (tex2D(_MainTex, v.texcoord));
        return color;
    }

    fixed4 frag_blur (v2f v) : SV_Target {
        int k = 1;
        /// _MainTex_TexelSize=> テクスチャのサイズ。
        float2 blurSize = _BlurSize * _MainTex_TexelSize.xy;
        float blurAlpha = 0;
        float2 tempCoord = float2(0,0);
        float tempAlpha;
        // -1 ~ 1でloop
        for (int px = -k; px <= k; px++) {
            // 同様に -1 ~ 1でloop
            for (int py = -k; py <= k; py++) {
                // 元のuv座標を受け取る
                tempCoord = v.texcoord;
                // そこからblurSize分x,yをずらす
                tempCoord.x += px * blurSize.x;
                tempCoord.y += py * blurSize.y;
                tempAlpha = tex2D(_MainTex, tempCoord).a;
                blurAlpha += tempAlpha;
            }
        }

        half4 blurColor = _BlurColor;
        blurColor.a *= blurAlpha;
        return blurColor;
    }
    ENDCG

    SubShader {
        // IgnoreProjector = >プロジェクターを無視する。部分的に透過するオブジェクトに対してプロジェクトターが有効だとウまくレンダリングできないのでTrueにしておく
        // プロジェクターとは　ビルトインパイプラインのみのきのう。  現実の名前の通り設定したマテリアルをプロジェクターのように投影する。
        // PreviewType＝＞プレビューをどれで表示させるか
        /// CanUseSpriteAtlas=>
        Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        //　カリングをしない
        Cull Off
        // ライティングをオフ
        Lighting Off
        // 深度値を書き込まない
        ZWrite Off
        // ZTest gui用のモード。CanvasのRenderModeの設定によって自動で変化する。
        // https://zenigane138.hateblo.jp/entry/2018/06/29/231816
        ZTest [unity_GUIZTestMode]
        // Blend => Shaderで計算した色 * SrcFactor + 既に画面に描画されている色 * DstFactor
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_blur
            ENDCG
        }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}