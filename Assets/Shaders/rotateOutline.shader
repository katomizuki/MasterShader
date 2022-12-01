Shader "Unlit/rotateOutline" {
    Properties {
        _MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
        _BlurColor ("Blur Color", Color) = (1, 1, 1, 1)
        _BlurSize ("Blur Size", float) = 1

        _Speed ("Speed", float) = 1
        _Angle ("Angle", Range(0, 1)) = 1
        _OffSet("xy : offset, zw : notUseing", Vector) = (0.5,0.5,0,0)
    }

    CGINCLUDE
    struct appdata {
        float4 vertex   : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f {
        float4 vertex   : SV_POSITION;
        half2 uv  : TEXCOORD0;
    };

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    fixed4 _BlurColor;
    float _BlurSize;
    half _Speed;
    half _Angle;
    fixed4 _OffSet;

    static const float PI = 3.14159265;

    v2f vert (appdata v) {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        return o;
    }

    fixed4 frag(v2f v) : SV_Target {
        half4 color = (tex2D(_MainTex, v.uv));
        return color;
    }

    fixed4 frag_blur (v2f v) : SV_Target {
        int k = 1;
        // blurSize(どれくらいずらしたいか）をスカラーとして扱ってuv座標をかける
        float2 blurSize = _BlurSize * _MainTex_TexelSize.xy;
        float blurAlpha = 0;
        float2 tempCoord = float2(0,0);
        float tempAlpha;
        // -1 ~ 1でforloop
        for (int px = -k; px <= k; px++) {
            for (int py = -k; py <= k; py++) {
                // uv座標を入れる
                tempCoord = v.uv;
                // x座標をblursize分ずらす
                tempCoord.x += px * blurSize.x;
                // y座標をblursize分ずらす
                tempCoord.y += py * blurSize.y;
                // アルファ値を計算する
                tempAlpha = tex2D(_MainTex, tempCoord).a;
                blurAlpha += tempAlpha;
            }
        }
        // ブラーカラー
        half4 blurColor = _BlurColor;
        half timeAngle = _Time.y * _Speed;
        // 回転座標
        half2x2 rotate = half2x2(cos(timeAngle), -sin(timeAngle), sin(timeAngle), cos(timeAngle));
        // uv-ずらしたいuv座標
        float2 offsetUv = v.uv - _OffSet.xy;
        // 回転行列を乗算する
        offsetUv = mul(rotate, offsetUv);
        // offset(x,y)座標が作るラジアン(-パイ ~ パイ）
        half uvAngle = atan2(offsetUv.y, offsetUv.x);
        // 許容する角度　6.28 * (-0.5 ~ 0.5) => (-パイ ~ パイ） をとりえる。Angleで調整可能
        half tolerance = (-_Angle + 0.5) * 2 * PI;
        // 指定した角度より大きければ0を返すようにする
        int angleStep = step(uvAngle, tolerance);
        // 乗算することで角度を調整する。
        offsetUv *= (offsetUv.xy * angleStep);
        // アルファ値を0of1に
        offsetUv = step(offsetUv, 0);
        // 0.001 0以上なら描画する
        offsetUv = offsetUv * step(0.001, blurAlpha);
        // a値をかける
        blurColor.a *= offsetUv;
        return blurColor;
    }
    ENDCG

    SubShader {
        Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
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