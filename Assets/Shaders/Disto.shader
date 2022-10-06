Shader "Unlit/Disto"
{
    Properties
    {
        _DistortionPower("Distortion Power", Range(0, 0.1)) = 0
        [HDR] _WaterColor("WaterColor", Color) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        // GrabPassを持つShaderごとにそれぞれ描画した内容が異なる場合がほとんどのためユニークな名前にする
        // Tagも使える。
        // 描画結果をテクスチャとして取得できる
        // 定義した時点での描画結果を取得できる。名前を定義してそれ以降のPassで利用することができる。
        GrabPass 
        {
            "_GrabPassTextureForDistortion"
        }
        //揺らぎの表現を頑張る　描画けかを利用する
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
                float4 grabPos : TEXCOORD1;
                float4 srcPos : TEXCOORD2;
            };

            sampler2D _CameraDepthTexture;
            // GrabPassで指定した名前でテキスチャをとってこれる。
            sampler2D _GrabPassTextureForDistortion;
            float _DistortionPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // 正しいテクスチャ座標を取得
                // GrabPassのテクスチャをサンプリングするUV座標はComputeGrabScreenPosで求める
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                // ComputeScreenPosによってxyが0~wに変換される。スクリーン座標に変換
                o.srcPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // サンプリングするUVをずらす　sin波でゆらゆら
                float2 distortion = sin(i.uv.y * 50 + _Time.w) * 0.1f;
                // Power->スケーラー
                distortion *= _DistortionPower;
                // 深度UV
                float4 depthUV = i.grabPos;
                // 歪みを大きくしておく
                depthUV.xy = i.grabPos.xy + distortion * 1.5;
                // 深度テクスチャをサンプリング　カメラデプステキスチャからカメラテキスチャをとってきて、第一引数をUV座標に変換して深度をする。
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(depthUV));
                // すでに描画済みのピクセルの深度情報 カメラ起点での深度をとってくる。
                float backgroundDepth = LinearEyeDepth(depthSample);
                // 今描画しようとしているピクセルの深度情報
                float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.srcPos.z);
                // Depthの差を利用した補間間
                float depthDiff = saturate(backgroundDepth - surfaceDepth);

                // w除算 普段はGPUが勝手にやってくれる
                // 補間間を利用してUVをずらして良いピクセルとそのままにするピクセルを塗り分け
                float2 uv = (i.grabPos.xy + distortion * depthDiff) / i.grabPos;
                return tex2D(_GrabPassTextureForDistortion, uv);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata 
            {
               float4 vertex : POSITION; 
            };

            struct v2f
            {
               float4 vertex : SV_POSITION; 
            };

            float4 _WaterColor;

            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _WaterColor;
            }
            ENDCG
        }
    }
}
