Shader "Unlit/ScanShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _LineColor("Line Color", color) = (1,1,1,1)
        [HDR] _TrajectoryColor("Trajectory Color", color) = (0.3,0.3,0.3,0.3)
        _LineSpeed("Line Speed", Float) = 1.0
        _LineSize("Line Size", Float) = 0.02
        _TrajectorySize("Trajectory Size", Float) = 1.0
        _IntervalSec("Interval", Float) = 2.0
        _MaxAlpha("Max Alpha", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

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
                float3 worldPos : WORLD_POS;
            };

            float4 _LineColor;
            float _LineSpeed;
            float _LineSize;
            float4 _TrajectoryColor;
            float _TrajectorySize;
            float _IntervalSec;
            float _MaxAlpha;
            float _TrajectoryAlpha;

            float _TimeFactor;
            float _AlphaFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float timeDelta = (_TimeFactor * _LineSpeed);
                // これでカメラの前方方向の向きを取得する。
                // 物体の進行ベクトル方向は(0,0,1)でそれを取り出すと M.m02_m12_m22
                // そもそもビュー行列はカメラの視点になるから移動と回転で作成したモデル行列の逆行列になっている。
                // 回転行列の逆行列は転置行列と一致する=>c,g,kが回転後のforwardベクトルだった。
                // -がついているのはプラットフォームの違いを吸収するため。
                // https://qiita.com/yuji_yasuhara/items/8d63455d1d277af4c270
                float dotResult = dot(i.worldPos, normalize(-UNITY_MATRIX_V[2].xyz));
                // 時間変化に伴い減衰
                float linePosition = abs(dotResult - timeDelta);
                // lineSizeが大きくなればなるほど1を返す率が高くなる。
                float scanLine = step(linePosition, _LineSize);
                // 補間値を逆転させる
                float trajectory = 1 - smoothstep(_LineSize, _LineSize + _TrajectorySize,linePosition);
                float alpha = 1 - smoothstep(_LineSize, (_LineSize + _TrajectorySize) * _TrajectoryAlpha, linePosition);
                float4 color = _LineColor * scanLine + _TrajectoryColor * trajectory;
                color.a = clamp(alpha * _AlphaFactor,0,_MaxAlpha);
                return color;
            }
            ENDCG
        }
    }
}
