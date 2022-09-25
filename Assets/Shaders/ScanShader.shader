Shader "Unlit/ScanShader"
{
    Properties
    {
        [HDR]_LineColor("Scan Line Color", Color) = (1, 1, 1, 1)
        [HDR]_TrajectoryColor("Scan Trajectory Color",Color) = (0.3, 0.3, 0.3, 0.3)
        _LineSpeed("Scan Line Speed", Float) = 1.0
        _LineSize("Scan Line Size", Float) = 0.02
        _TrajectorySize("Scan Trajectory Size", Float) = 1.0
        _IntervalSec("Scan Interval", Float) = 2.0
        _MaxAlpha("Max Alpha",Range(0, 1)) = 0.5
        _TrajectoryAlpha("Trajectory Alpha", Range(0.1,1)) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent"
        }
        
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
                float3 worldPos : WORLD_POS;
                float4 vertex : SV_POSITION;
            };
            
            float4 _LineColor;
            float _LineSpeed;
            float _LineSize;
            float4 _TrajectoryColor;
            float _TrajectorySize;
            float _IntervalSec;
            float _MaxAlpha;
            float _TrajectoryAlpha;

            // C#から受け取る
            float _TimeFactor;
            float _AlphaFactory;

            v2f vert (appdata v)
            {
                v2f o;
                // unity_ObjectToWorldと頂点座標をmul(行列の掛け算）することで描画しようとしているピクセルのワールド座標をえる
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // スキャンの時間のスピード
                float timeDelta = (_TimeFactor * _LineSpeed);
                
                // カメラの正面方向にエフェクトを進める
                // -UNITY_MATRIX_V[2].xyzでWorldSpaceのカメラの向きが取得できる
                // カメラの向きとワールド座標の内積を出す。-1 ~ 1
                float dotResult = dot(i.worldPos, normalize(-UNITY_MATRIX_V[2].xyz));
                
                // 時間変換に伴い値を減算した値を絶対値として繰り返しになるようにする。
                float linePosition = abs(dotResult - timeDelta);
                
                // スキャンラインの大きさを計算するstep(a, b)はbがaより大きい場合1を返す。
                // _LineSizeがlinePositionより大きくなれば1を返す。それ以外は0
                // LineSizeが大きければ1を返す時が大きくなるのでScanLineも大きくなる
                float scanLine = step(linePosition, _LineSize);

                
                // 軌跡の大きさ(_TrajectorySizeはスカラー)を計算smoothstemp(a,b,c)はcがa以下の時は0 b以上の場合は1 0 ~ 1は補間
                // 1 - smoothstep(a,b,c)とすることで補間間
                // 1 - smoothstempでcがa以上は1 b以下の時は0, 0 ~ 1は補間
                // 反転している 1 ~ 0
                float trajectory = 1 - smoothstep(_LineSize, _LineSize + _TrajectorySize, linePosition);
                // 同様にして徐々に通過させる
                float alpha = 1 - smoothstep(_LineSize, (_LineSize + _TrajectorySize) * _TrajectoryAlpha, linePosition);
                // 計算を色に変換　LineColor * (1 or 0) + 軌跡の色　* trajectory（軌跡の色のsmooth)
                float4 color = _LineColor * scanLine + _TrajectoryColor * trajectory;
                // 透明度の調整 clamp(a,b,c) aのあたいをb ~ cの間におさめる 0 _MaxAlphaの間におさめる
                color.a = clamp(alpha * _AlphaFactory, 0, _MaxAlpha);
                return color;
            }
            ENDCG
        }
    }
}
