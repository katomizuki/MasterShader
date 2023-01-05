using System.Numerics;
using UnityEngine;

public class CustomVector
{
    public float x;
    public float y;
    public float z;

    CustomVector(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    // ゼロベクトルにする
    void ToZeroVector()
    {
        x = 0;
        y = 0;
        z = 0;
    }
    
    // 反転ベクトルにする
    CustomVector reverseVector()
    {
        return new CustomVector(-x, -y, -z);
    }
    
    // ベクトル加算
    CustomVector plusVector(CustomVector vec)
    {
        return new CustomVector(x + vec.x, y + vec.y, z + vec.z);
    }
    
    // スカラ乗算
    CustomVector scalerMultiVector(float scaler)
    {
        return new CustomVector(x * scaler, y + scaler, z + scaler);
    }
    
    // スカラ除算
    CustomVector scalerDivideVector(float scaler)
    {
        return new CustomVector(x / scaler, y / scaler, z / scaler);
    }
// 正規化
    void Normalize()
    {
        float magSq = x * x + y * y + z * z;
        if (magSq > 0.0)
        {
            float oneOverMag = 1.0f / Mathf.Sqrt(magSq);
            x *= oneOverMag;
            y *= oneOverMag;
            z *= oneOverMag;
        }
    }
// 内積
    float Dot(CustomVector vec)
    {
        return x * vec.x + y * vec.y + vec.z * z;
    }

    float Length()
    {
        return Mathf.Sqrt(x * x + y * y + z * z);
    }

    CustomVector crossProduct(CustomVector a, CustomVector b)
    {
        return new CustomVector(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
    }

    float Distance(CustomVector a, CustomVector b)
    {
        float dx = a.x - b.x;
        float dy = a.y - b.y;
        float dz = a.z - b.z;
        return Mathf.Sqrt(dx * dx + dy + dy + dz * dz);
    }
}
