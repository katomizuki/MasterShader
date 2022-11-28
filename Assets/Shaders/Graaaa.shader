Shader "Unlit/Graaaa"
{
    Properties
    {
        _NoiseTailingOffset("TailingOffset", Vector) = (0.1,0.1,0.1)
        _NoiseSizeScroll("NoiseTex", Vector) = (16, 16, 0, 0)
        _DistortionPower("Distortion Power", Float ) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        // フラグメントシェーダーでリターンされた色にScrAlphaをかける
        // 処理まえの色にかける。
        // Shaderで計算した色 * SrcFactor + 既に画面に描画されている色 * DstFactor
        // 一般的な透過設定
        Blend SrcAlpha OneMinusAlpha
        // GrabPassでカメラのテキスちゃを参照する
        GrabPass { "_BackgroundTexture" } 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "noiseutil.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 grabuv : TEXCOORD0;
                float2 noiseuv : TEXCOORD1;
            };

            sampler2D _BackgroundTexture;
            fixed4 _NoiseTailingOffset;
            fixed4 _NoiseSizeScroll;
            float _DistortionPower;

            v2f vert (appdata v)
            {
                v2f o;
                // MVP変換変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                // GrabPassで取得したテクスチャのUV座標を取得
                o.grabuv = ComputeGrabScreenPos(o.vertex);
                o.noiseuv = TRANSFORM_NOISE_TEX(v.uv, _NoiseTailingOffset, _NoiseSizeScroll);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 歪み（x ,y,z方向への歪み）
                fixed3 dist = normalNoise(i.noiseuv, _NoiseSizeScroll);
                // 0~1 => -1 ~ 1に変換する
                dist = dist * 2 - 1;
                // スケーラーを乗算
                dist *= _DistortionPower;
                // 実際に加算して動かす
                i.grabuv.xy += dist.xy;
                // wで除算してからtex2Dを行う関数
                // Unity_proj_coord=>テクスチャ座標を適切なテクスチャ座標に変換するもの(プラットフォームごとのと違いを吸収してくれているだけ）
                fixed4 col = tex2Dproj(_BackgroundTexture, UNITY_PROJ_COORD(i.grabuv));
                return col;
            }
            ENDCG
        }
    }
}
